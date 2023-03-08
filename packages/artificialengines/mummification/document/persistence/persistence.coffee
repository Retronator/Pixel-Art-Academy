AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Persistence
  # Enabling persistence on a document works with the following fields on the document:
  # profileId: an identifier that ties all persistent documents together to a single profile, owned by a user
  # lastEditTime: the time the document was last edited
  
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
    
  @registerSyncedStorage: (syncedStorage) ->
    @_syncedStoragesById[syncedStorage.id()] = syncedStorage

  @availableProfiles: ->
    # TODO: Query all registered storages for profiles and merge them together into available profiles.
    
  @createProfile: ->
  
  
  @loadProfile: (profileId) ->
    # Fetch all profile documents from all storages and resolve conflicts.
    new Promise (resolve, reject) =>
      @_activeProfile =
        id: profileId
        
      resolve()

  @flushUpdates: ->
    # Flush any throttled updates.
