AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Persistence
  # Enabling persistence on a document works with the following fields on the document:
  # profileId: an identifier that ties all persistent documents together to a single profile, owned by a user
  # lastEditTime: the time the document was last edited
  
  @ConflictResolutionStrategies =
    Latest: 'Latest'
  
  @_persistentDocumentClassesById = {}
  @_syncedStoragesById = {}
  @_activeProfile = null

  @initializeDocumentClass: (documentClass) ->
    return if Meteor.isServer
    return if documentClass.isPersistent
  
    documentClass.isPersistent = true
    @_persistentDocumentClassesById[documentClass.id()] = documentClass
  
    # Replace documents with a local collection that can be directly written to and we can observe the changes.
    documentClass.serverDocuments = documentClass.documents
    documentClass.documents = new AM.Document.Persistence.PersistentCollection documentClass
    documentClass.documents.fetch = ->
      cursor = documentClass.documents.find arguments...
      cursor.fetch()
  
    # Use latest resolution strategy by default.
    documentClass.conflictResolutionStrategy ?= @ConflictResolutionStrategies.Latest
    
  @registerSyncedStorage: (syncedStorage) ->
    @_syncedStoragesById[syncedStorage.id()] = syncedStorage

  @availableProfiles: ->
    # TODO: Query all registered storages for profiles and merge them together into available profiles.
    
  @createProfile: ->
    new Promise (resolve, reject) =>
      profileId = Random.id()
      
      Persistence.Profile.documents.insert
        _id: profileId
        syncedStorages: {}
      
      @loadProfile(profileId).then =>
        resolve profileId
  
  @loadProfile: (profileId) ->
    throw new AE.InvalidOperationException "A profile is already loaded. Unload it first before proceeding." if @_activeProfile
  
    @_activeProfile = Persistence.Profile.documents.findOne profileId
  
    throw new AE.ArgumentException "A profile with the given ID was not found", profileId unless @_activeProfile
    
    # Fetch all profile documents from all storages and resolve conflicts.
    new Promise (resolve, reject) =>
      loadPromises = for syncedStorageId, syncedStorage of @_syncedStoragesById when @_activeProfile.syncedStorages[syncedStorageId]
        syncedStorage.loadDocumentsForProfileId profileId
    
      Promise.all(loadPromises).then (loadDocumentsResults) =>
        documentClonesByClassIdAndId = {}
        _.merge documentClonesByClassIdAndId, loadDocumentsResults
  
        documentsByClassIdAndId = {}
        conflictingDocumentClonesByClassIdAndId = {}
        conflicts = false
  
        for documentClassId, documentClonesById of documentClonesByClassIdAndId
          documentsById = {}
          documentsByClassIdAndId[documentClassId] = documentsById
  
          conflictingDocumentClonesById = {}
          conflictingDocumentClonesByClassIdAndId[documentClassId] = conflictingDocumentClonesById
          
          documentClass = AM.Document.getClassForId documentClassId
          
          for documentId, documentClones of documentClonesById
            lastEditTime = null
            conflict = false
          
            for syncedStorageId, documentClone of documentClones
              lastEditTime = documentClone.lastEditTime unless lastEditTime
              if lastEditTime isnt documentClone.lastEditTime
                conflict = true
                break
                
            if conflict
              # See if we can employ a resolution strategy.
              switch documentClass.conflictResolutionStrategy
                when @ConflictResolutionStrategies.Latest
                  # Simply choose the clone with the latest last edit time.
                  resolvedDocument = _.maxBy _.values(documentClones), (document) => document.lastEditTime
                  conflict = false
                  
            else
              resolvedDocument = documentClones[0]
          
            if conflict
              conflictingDocumentClonesById[document.id] = documentClones
              conflicts = true
              
            else
              documentsById[document.id] = resolvedDocument
          
        if conflicts
          reject
            conflictingDocumentClonesByClassIdAndId: conflictingDocumentClonesByClassIdAndId
            resolutionCallback: (resolutionPromise) =>
              # We expect the caller of the method to return a promise for resolving the conflict.
              resolutionPromise.then (documentsByClassIdAndId) =>
                # The conflict was resolved and we received the chosen documents.
                # TODO: Probably what we want is to receive a resolution strategy and we perform the resolution here.
                @_endLoad documentsByClassIdAndId
              
        else
          @_endLoad documentsByClassIdAndId
          resolve()

  @_endLoad: (documentsByClassIdAndId) ->
    # Insert all documents belonging to this profile.
    for documentClassId, documentsById of documentsByClassIdAndId
      documentClass = AM.Document.getClassForId documentClassId
    
      for documentId, document of documentsById
        documentClass.documents.insert document

  @unloadProfile: ->
    throw new AE.InvalidOperationException "There is no loaded profile to unload." unless @_activeProfile

    @flushChanges().then =>
      # Deactivate the profile first so that removals will not be seen as active actions.
      profileId = @_activeProfile._id
      @_activeProfile = null

      # Remove all documents belonging to the active profile.
      for documentId, documentClass of @_persistentDocumentClassesById
        documentClass.documents.remove {profileId}

  @flushChanges: ->
    # Flush any throttled changes.
    flushUpdatesPromises = for syncedStorageId, syncedStorage of @_syncedStoragesById
      syncedStorage.flushChanges()
  
    Promise.all flushUpdatesPromises
    
  # Methods for internal use by synced storages
  
  @added: (document) -> @_informStorages document, 'added'
  @changed: (document) -> @_informStorages document, 'changed'
  @removed: (document) -> @_informStorages document, 'removed'
  
  @_informStorages: (document, methodName) ->
    return unless @_activeProfile
    
    promises = for syncedStorageId, syncedStorage of @_syncedStoragesById when @_activeProfile.syncedStorages[syncedStorageId]
      syncedStorage[methodName] document
  
    Promise.all promises
