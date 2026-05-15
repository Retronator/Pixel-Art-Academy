AM = Artificial.Mirage
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PAA.LearnMode

Persistence = Artificial.Mummification.Document.Persistence

class LM.SyncedStorageMigration extends AM.Component
  @id: -> 'PixelArtAcademy.LearnMode.SyncedStorageMigration'
  @register @id()
  
  mixins: -> [@activatable]
  
  constructor: (@profileId, @existingSyncedStorageId, @newSyncedStorageId) ->
    super arguments...
    
    @activatable = new LOI.Components.Mixins.Activatable
    
  onCreated: ->
    super arguments...
    
    @migratingTextVisible = new ReactiveField false
    @showMigratingPercentage = new ReactiveField false
    @compressingStoragePercentage = new ReactiveField 0
    
  onActivate: (finishedActivatingCallback) ->
    @compressingStoragePercentage 0
    LOI.adventure.menu.loadGame.audio.load true
    @showMigratingPercentage false
    await _.waitForSeconds 0.5
    finishedActivatingCallback()
    
    @migratingTextVisible true
    
    profile = Persistence.Profile.documents.findOne @profileId
    loadedProfile = LOI.adventure.profile()
    
    throw new AE.InvalidOperationException "Profile was already loaded while attempting to migrate a different profile's synced storage." if loadedProfile and loadedProfile._id isnt @profileId
    
    try
      await Persistence.loadProfile @profileId unless loadedProfile
      @showMigratingPercentage true
      
      if Meteor.isDesktop
        await Persistence.addSyncingToProfile @newSyncedStorageId unless profile.syncedStorages[@newSyncedStorageId]
        await Persistence.removeSyncingFromProfile @existingSyncedStorageId if profile.syncedStorages[@existingSyncedStorageId]
        
        newSyncedStorage = Persistence.getSyncedStorage @newSyncedStorageId
        await newSyncedStorage.compressStorage @profileId,
          onProgress: (progress) =>
            @compressingStoragePercentage progress * 100
        
      else
        # Wait for browser testing purposes.
        await _.waitForSeconds 2
        
      Persistence.unloadProfile() unless loadedProfile
    
    catch error
      console.error error
    
    finally
      @migratingTextVisible false
      LOI.adventure.menu.loadGame.audio.load false
      @activatable.deactivate()
    
  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500
  
  migratingTextVisibleClass: ->
    'visible' if @migratingTextVisible()
  
  migratingPercentage: ->
    Math.floor Persistence.addingSyncingPercentage() * 0.9 + @compressingStoragePercentage() * 0.1
