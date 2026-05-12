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
  
  onCreated: ->
    super arguments...
    
    @migratingVisible = new ReactiveField false
    @migratingTextVisible = new ReactiveField false
    @showMigratingPercentage = new ReactiveField false
  
  editingProfileHasSteamCloud: ->
    profile = Persistence.Profile.documents.findOne @editingProfileId()
    profile.syncedStorages[Persistence.SyncedStorages.SteamCloud.id()]
  
  showBackButton: ->
    not (@loadingVisible() or @autoLoadedProfileId() or @migratingVisible())
  
  progressOverlayVisibleClass: ->
    'visible' if @loadingProfileId() or @migratingVisible()
    
  migratingVisibleClass: ->
    'visible' if @migratingVisible()
  
  migratingTextVisibleClass: ->
    'visible' if @migratingTextVisible()
  
  migratingPercentage: ->
    Math.floor Persistence.addingSyncingPercentage()
    
  events: ->
    super(arguments...).concat
      'click .enable-steam-cloud-button': @onClickEnableSteamButton
      'click .disable-steam-cloud-button': @onClickDisableSteamButton
  
  onClickEnableSteamButton: (event) ->
    profile = Persistence.Profile.documents.findOne @editingProfileId()
    profileName = profile.displayName or profile._id
    
    steam = AT.Steam.instance()
    
    dialog = new LOI.Components.Dialog
      message: "Enabling Steam Cloud will sync the #{profileName} save game with your #{steam.player.name} Steam account. You will have to be logged in to Steam to see this save game."
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
    profileName = profile.displayName or profile._id
    
    dialog = new LOI.Components.Dialog
      message: "Disabling Steam Cloud will make the #{profileName} save game available only locally on this computer."
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
    @audio.load true
    @showMigratingPercentage false
    @migratingVisible true
    await _.waitForSeconds 0.5
    @migratingTextVisible true
    
    profile = Persistence.Profile.documents.findOne profileId
    
    try
      await Persistence.loadProfile profileId
      @showMigratingPercentage true
      
      if Meteor.isDesktop
        await Persistence.addSyncingToProfile newSyncedStorageId unless profile.syncedStorages[newSyncedStorageId]
        await Persistence.removeSyncingFromProfile existingSyncedStorageId if profile.syncedStorages[existingSyncedStorageId]
        
      else
        # Wait for browser testing purposes.
        await _.waitForSeconds 2
        
      Persistence.unloadProfile()
    
    catch error
      console.error error
    
    finally
      @migratingVisible false
      @migratingTextVisible false
      @audio.load false
