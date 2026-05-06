AB = Artificial.Base
AT = Artificial.Telepathy
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Persistence = Artificial.Mummification.Document.Persistence

# Adventure overrides for stand-alone learn mode builds.
class LM.Adventure extends LM.Adventure
  @rootUrl: -> '/'

  @saveGameClass: -> LM.SaveGame
  
  getLocalSyncedStorage: ->
    if Meteor.isDesktop
      new Persistence.SyncedStorages.FileSystem
        relativeDirectoryPath: 'saves'
        relativeBackupDirectoryPath: 'save backups'

    else
      super arguments...
  
  registerSyncedStorages: ->
    if Meteor.isDesktop
      @autorun (computation) =>
        return unless AB.DistributionPlatform.type()
        computation.stop()
        
        if AB.DistributionPlatform.isSteam
          steam = AT.Steam.instance()
          
          @steamCloudSyncedStorage = new Persistence.SyncedStorages.SteamCloud
            relativeDirectoryPath: "steam saves/#{steam.player.steamId64}"
            relativeBackupDirectoryPath: 'save backups'
      
          Persistence.registerSyncedStorage @steamCloudSyncedStorage
      
      @fileSystemSyncedStorage = new Persistence.SyncedStorages.FileSystem
        relativeDirectoryPath: 'saves'
        relativeBackupDirectoryPath: 'save backups'
        
      Persistence.registerSyncedStorage @fileSystemSyncedStorage
      
    else
      @indexedDBSyncedStorage = new Persistence.SyncedStorages.IndexedDB databaseName: "Retronator"
      Persistence.registerSyncedStorage @indexedDBSyncedStorage
      
  saveGame: (options) ->
    super arguments...
    
    if Meteor.isDesktop
      syncedStorage = if options.steamCloud then @steamCloudSyncedStorage else @fileSystemSyncedStorage
      
    else
      syncedStorage = @indexedDBSyncedStorage

    Persistence.addSyncingToProfile syncedStorage.id()
  
  endRun: ->
    if Meteor.isDesktop
      # Override to not perform any database flush behaviors since we don't
      # know if the OS will give us the time to perform the saves in time.
      return
    
    super arguments...
