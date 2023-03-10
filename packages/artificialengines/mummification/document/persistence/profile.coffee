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
    
  @enablePersistence()
  
  hasSyncing: ->
    _.keys(@syncedStorages).length > 0
