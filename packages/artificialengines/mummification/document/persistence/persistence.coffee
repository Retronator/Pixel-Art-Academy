AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Persistence
  # Enabling persistence on a document works with the following fields on the document:
  # profileId: an identifier that ties all persistent documents together to a single profile, owned by a user
  # lastEditTime: the time the document was last edited
  
  @debug = false
  
  @ConflictResolutionStrategies =
    Latest: 'Latest'
    ManualUser: 'ManualUser'
    ManualDocument: 'ManualDocument'
  
  @_persistentDocumentClassesById = {}
  @_syncedStoragesById = {}
  @_syncedStoragesDependency = new Tracker.Dependency

  @_profileLoadingPercentagesById = {}
  @_profileLoadingPercentageDependency = new Tracker.Dependency
  
  @_activeProfileId = new ReactiveField null
  
  @profileReady = new ReactiveField false
  
  Meteor.startup =>
    @activeProfile = new ComputedField =>
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
  
    # Use latest resolution strategy by default.
    documentClass.conflictResolutionStrategy ?= @ConflictResolutionStrategies.Latest
    
  @registerSyncedStorage: (syncedStorage) ->
    console.log "Registered synced storage", syncedStorage.id() if @debug
    @_syncedStoragesById[syncedStorage.id()] = syncedStorage
    @_syncedStoragesDependency.changed()
    
  @hasSyncedStorage: (syncedStorageId) -> @_syncedStoragesById[syncedStorageId]
    
  @ready: ->
    @_syncedStoragesDependency.depend()
    
    if @debug
      console.log "Synced storages ready?"
      console.log id, syncedStorage.ready() for id, syncedStorage of @_syncedStoragesById
    
    for id, syncedStorage of @_syncedStoragesById
      return false unless syncedStorage.ready()
      
    true
    
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
    console.log "Persistence loading profile", profileId if @debug
    
    throw new AE.InvalidOperationException "A profile is already loaded. Unload it first before proceeding." if @_activeProfileId()
  
    profile = Persistence.Profile.documents.findOne profileId
  
    throw new AE.ArgumentException "A profile with the given ID was not found", profileId unless profile
    
    @_activeProfileId profileId
    
    # Fetch all profile documents from all storages and resolve conflicts.
    new Promise (resolve, reject) =>
      loadPromises = for syncedStorageId, syncedStorage of @_syncedStoragesById when profile.syncedStorages[syncedStorageId]
        do (syncedStorageId) =>
          @_profileLoadingPercentagesById[syncedStorageId] = 0
          
          syncedStorage.loadDocumentsForProfileId(profileId,
            onProgress: (progressValue) =>
              @_profileLoadingPercentagesById[syncedStorageId] = progressValue * 100
              @_profileLoadingPercentageDependency.changed()
          
          ).catch (error) =>
            console.error "Loading documents from synced storage", syncedStorageId, "failed.", error
            throw error
      
      @_profileLoadingPercentageDependency.changed()
      
      Promise.all(loadPromises).then (loadDocumentsResults) =>
        console.log "Loaded document results", loadDocumentsResults if @debug
        
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

      , (error) =>
        # Pass the error to the outer promise. Note that we cannot throw here as that would be a throw in the internal
        # promise (the one started with the .all promise) and would simply result in a promise with an unhandled
        # exception (since this internal promise is not returned/chained out of the outer promise to hook into its own
        # catch blocks. Therefore we need to explicitly reject the outer promise.
        reject error
        
  @profileLoadingPercentage: ->
    @_profileLoadingPercentageDependency.depend()
    
    minimumLoadingPercentage = 100
    
    for syncedStorageId, loadingPercentage of @_profileLoadingPercentagesById
      minimumLoadingPercentage = Math.min minimumLoadingPercentage, loadingPercentage
      
    minimumLoadingPercentage

  @_endLoad: (documentsByClassIdAndId) ->
    console.log "Profile documents retrieved …" if @debug
    
    # Insert all documents belonging to this profile.
    for documentClassId, documentsById of documentsByClassIdAndId
      documentClass = AM.Document.getClassForId documentClassId
      
      unless documentClass
        console.warn "Documents saved for unknown class", documentClassId
        continue
    
      for documentId, document of documentsById
        documentClass.documents.insert document
        
    console.log "Profile documents inserted. Profile ready." if @debug
  
    @profileReady true

  @unloadProfile: ->
    profileId = @_activeProfileId()
    throw new AE.InvalidOperationException "There is no loaded profile to unload." unless profileId
  
    console.log "Persistence unloading profile", profileId if @debug
    
    @profileReady false
  
    @flushChanges().then =>
      # Deactivate the profile first so that removals will not be seen as active actions.
      @_activeProfileId null
      
      console.log "Persistence profile deactivated. Removing documents …", profileId if @debug

      # Remove all documents belonging to the active profile, except profiles.
      for documentClassId, documentClass of @_persistentDocumentClassesById when documentClassId isnt @Profile.id()
        documentClass.documents.remove {profileId}

      console.log "Profile documents removed." if @debug
  
  @flushChanges: ->
    # Flush any throttled changes.
    flushUpdatesPromises = for syncedStorageId, syncedStorage of @_syncedStoragesById
      syncedStorage.flushChanges()
  
    Promise.all flushUpdatesPromises
    
  @addSyncingToProfile: (syncedStorageId) ->
    profile = @activeProfile()
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

    # Only sync documents belonging to the active profile. Note: We want to check _activeProfileId directly because
    # _activeProfile only gets created after startup, but assets (without profile ID) can already start being added
    # before that happens.
    return unless document.profileId and document.profileId is @_activeProfileId()
    
    return unless activeProfile = @activeProfile()
    
    promises = for syncedStorageId, syncedStorage of @_syncedStoragesById when activeProfile.syncedStorages[syncedStorageId]
      syncedStorage[methodName] document
  
    Promise.all promises
