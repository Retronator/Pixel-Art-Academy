AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Persistence
  # Enabling persistence on a document works with the following fields on the document:
  # profileId: an identifier that ties all persistent documents together to a single profile, owned by a user
  # lastEditTime: the time the document was last edited
  
  @debug = true
  
  @ConflictResolutionStrategies =
    Latest: 'Latest'
    ManualUser: 'ManualUser'
    ManualDocument: 'ManualDocument'
  
  @_persistentDocumentClassesById = {}
  @_syncedStoragesById = {}

  @_activeProfileId = new ReactiveField null
  
  Meteor.startup =>
    @_activeProfile = new ComputedField =>
      @Profile.documents.findOne @_activeProfileId()
    ,
      true

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
    
  @createProfile: ->
    new Promise (resolve, reject) =>
      profileId = Random.id()
      
      Persistence.Profile.documents.insert
        _id: profileId
        profileId: profileId
        lastEditTime: new Date
        syncedStorages: {}
      
      @loadProfile(profileId).then =>
        resolve profileId
  
  @loadProfile: (profileId) ->
    throw new AE.InvalidOperationException "A profile is already loaded. Unload it first before proceeding." if @_activeProfileId()
  
    profile = Persistence.Profile.documents.findOne profileId
  
    throw new AE.ArgumentException "A profile with the given ID was not found", profileId unless profile
    
    @_activeProfileId profileId
    
    # Fetch all profile documents from all storages and resolve conflicts.
    new Promise (resolve, reject) =>
      loadPromises = for syncedStorageId, syncedStorage of @_syncedStoragesById when profile.syncedStorages[syncedStorageId]
        syncedStorage.loadDocumentsForProfileId profileId
    
      Promise.all(loadPromises).then (loadDocumentsResults) =>
        documentClonesByClassIdAndId = {}
        _.merge documentClonesByClassIdAndId, loadDocumentsResults...
  
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
                  
                when @ConflictResolutoinStrategies.ManualDocument
                  # Ask the document class to resolve the conflict.
                  resolvedDocument = documentClass.onConflict documentClones
                  
            else
              resolvedDocument = _.values(documentClones)[0]
          
            if conflict
              conflictingDocumentClonesById[documentId] = documentClones
              conflicts = true
              
            else
              documentsById[documentId] = resolvedDocument
          
        if conflicts
          reject
            conflictingDocumentClonesByClassIdAndId: conflictingDocumentClonesByClassIdAndId
            resolutionCallback: (resolutionPromise) =>
              # We expect the caller of the method to return a promise for resolving the conflict.
              resolutionPromise.then (resolvedDocumentsByClassIdAndId) =>
                # The conflict was resolved and we received the chosen documents.
                _.merge documentsByClassIdAndId, resolvedDocumentsByClassIdAndId
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
    profileId = @_activeProfileId()
    throw new AE.InvalidOperationException "There is no loaded profile to unload." unless profileId

    @flushChanges().then =>
      # Deactivate the profile first so that removals will not be seen as active actions.
      @_activeProfileId null

      # Remove all documents belonging to the active profile.
      for documentClassId, documentClass of @_persistentDocumentClassesById
        documentClass.documents.remove {profileId}

  @flushChanges: ->
    # Flush any throttled changes.
    flushUpdatesPromises = for syncedStorageId, syncedStorage of @_syncedStoragesById
      syncedStorage.flushChanges()
  
    Promise.all flushUpdatesPromises
    
  @addSyncingToProfile: (syncedStorageId) ->
    profile = @_activeProfile()
    throw new AE.InvalidOperationException "There is no loaded profile to add syncing to." unless profile
  
    throw new AE.ArgumentException "The profile is already syncing with this synced storage." if profile.syncedStorages.syncedStorageId

    Persistence.Profile.documents.update profile._id,
      $set:
        "syncedStorages.#{syncedStorageId}": {}
        lastEditTime: new Date
        
    # Add all documents to the new synced storage.
    syncedStorage = @_syncedStoragesById[syncedStorageId]
  
    for documentClassId, documentClass of @_persistentDocumentClassesById
      documentClass.documents.find(profileId: profile._id).forEach (document) => syncedStorage.added document
    
  # Methods for internal use by synced storages
  
  @addProfiles: (syncedStorageId, profiles) ->
    console.log "Adding profiles", syncedStorageId, profiles if @debug
  
    for profile in profiles
      if existingProfile = Persistence.Profile.documents.findOne profile._id
      
        unless existingProfile.lastEditTime is profile.lastEditTime
          resolvedProfile = Persistence.Profile.onConflict
            "#{Persistence.Profile.id()}": existingProfile
            "#{syncedStorageId}": profile
  
          Persistence.Profile.documents.update resolvedProfile._id, resolvedProfile

      else
        Persistence.Profile.documents.insert profile

  # Methods for internal use by persistent collections
  
  @added: (document) -> @_informStorages document, 'added'
  @changed: (document) -> @_informStorages document, 'changed'
  @removed: (document) -> @_informStorages document, 'removed'
  
  @_informStorages: (document, methodName) ->
    console.log "Document", methodName, document if @debug
    
    return unless activeProfile = @_activeProfile()
    
    promises = for syncedStorageId, syncedStorage of @_syncedStoragesById when activeProfile.syncedStorages[syncedStorageId]
      syncedStorage[methodName] document
  
    Promise.all promises
