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
  @loadGameClass: -> LM.LoadGame
  
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
  
  loadGame: ->
    await super arguments...
    await _.waitForFlush()

    # Offer the user to migrate to Steam Cloud.
    if steam = AT.Steam.instance()
      profile = LOI.adventure.profile()
      
      unless profile.syncedStorages[Persistence.SyncedStorages.SteamCloud.id()] or profile.informedAboutSteamCloud
        dialog = new LOI.Components.Dialog
          message: """Steam Cloud saves are now available! Do you want to enable Steam Cloud for this save game?
          
                      Enabling Steam Cloud will sync the #{profile.debugName()} save game with your #{steam.player.name} Steam account. You will have to be logged in to Steam to see this save game."""
          buttons: [
            text: "Enable"
            value: true
          ,
            text: "Cancel"
          ]
        
        await LOI.adventure.showActivatableModalDialog
          dialog: dialog
          callback: =>
            Persistence.Profile.documents.update profile._id,
              $set:
                lastEditTime: new Date()
                informedAboutSteamCloud: true
                
        if dialog.result
          syncedStorageMigration = new LM.SyncedStorageMigration profile._id, Persistence.SyncedStorages.FileSystem.id(), Persistence.SyncedStorages.SteamCloud.id()
          await LOI.adventure.showActivatableModalDialog dialog: syncedStorageMigration

  endRun: ->
    if Meteor.isDesktop
      # Override to not perform any database flush behaviors since we don't
      # know if the OS will give us the time to perform the saves in time.
      return
    
    super arguments...
