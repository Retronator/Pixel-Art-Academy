AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification
Persistence = AM.Document.Persistence

class Persistence.Profile extends AM.Document
  @id: -> 'Artificial.Mummification.Document.Persistence.Profile'
  # profileId: same as _id, but needed as it is itself a persistent document
  # lastEditTime: the time the whole profile was last synced (updates with every document save)
  # syncedStorages: an object with extra data for each synced storage this profile is synced to.
  #   {syncedStorageId}
  @Meta
    name: @id()
    
  @conflictResolutionStrategy = Persistence.ConflictResolutionStrategies.ManualDocument
  
  @enablePersistence()
  
  @onConflict: -> (documentClones) ->
    # We want to take the latest documents, except for synced storages where each provider has their own priority.
    resolvedDocument = _.cloneDeep _.maxBy _.values(documentClones), (document) => document.lastEditTime
  
    # Note that for profiles we're always resolving a conflict against a version already in memory so the synced
    # storage ID in that case will be the document ID itself (meaning we will not have an entry in synced storages
    # for it.
    profileClassId = @id()
    resolvedDocument.syncedStorages = _.clone documentClones[profileClassId].syncedStorages
    
    for syncedStorageId, documentClone of documentClones when syncedStorageId isnt profileClassId
      resolvedDocument.syncedStorages[syncedStorageId] = documentClone.syncedStorages[syncedStorageId]

    resolvedDocument

  hasSyncing: ->
    _.keys(@syncedStorages).length > 0
