AB = Artificial.Babel
AC = Artificial.Control
AM = Artificial.Mirage
AEc = Artificial.Echo
AT = Artificial.Telepathy
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PAA.LearnMode

Persistence = Artificial.Mummification.Document.Persistence

class LM.LoadGame extends LOI.Components.LoadGame
  @id: -> 'PixelArtAcademy.LearnMode.LoadGame'
  @register @id()
  
  editingProfileHasSteamCloud: ->
    profile = Persistence.Profile.documents.findOne @editingProfileId()
    profile.syncedStorages[Persistence.SyncedStorages.SteamCloud.id()]
  
  events: ->
    super(arguments...).concat
      'click .enable-steam-cloud-button': @onClickEnableSteamButton
      'click .disable-steam-cloud-button': @onClickDisableSteamButton
  
  onClickEnableSteamButton: (event) ->
    profile = Persistence.Profile.documents.findOne @editingProfileId()
    
    steam = AT.Steam.instance()
    
    dialog = new LOI.Components.Dialog
      message: "Enabling Steam Cloud will sync the #{profile.debugName()} save game with your #{steam.player.name} Steam account. You will have to be logged in to Steam to see this save game."
      buttons: [
        text: "Enable"
        value: true
      ,
        text: "Cancel"
      ]
      
    LOI.adventure.showActivatableModalDialog
      dialog: dialog
      callback: =>
        return unless dialog.result
        
        @_migrateSyncedStorage profile._id, Persistence.SyncedStorages.FileSystem.id(), Persistence.SyncedStorages.SteamCloud.id()
  
  onClickDisableSteamButton: (event) ->
    profile = Persistence.Profile.documents.findOne @editingProfileId()
    
    dialog = new LOI.Components.Dialog
      message: "Disabling Steam Cloud will make the #{profile.debugName()} save game available only locally on this computer."
      buttons: [
        text: "Disable"
        value: true
      ,
        text: "Cancel"
      ]
    
    LOI.adventure.showActivatableModalDialog
      dialog: dialog
      callback: =>
        return unless dialog.result
        
        @_migrateSyncedStorage profile._id, Persistence.SyncedStorages.SteamCloud.id(), Persistence.SyncedStorages.FileSystem.id()
        
  _migrateSyncedStorage: (profileId, existingSyncedStorageId, newSyncedStorageId) ->
    Persistence.Profile.documents.update profileId,
      $set:
        lastEditTime: new Date()
        informedAboutSteamCloud: true
        
    syncedStorageMigration = new LM.SyncedStorageMigration profileId, existingSyncedStorageId, newSyncedStorageId
    LOI.adventure.showActivatableModalDialog dialog: syncedStorageMigration
