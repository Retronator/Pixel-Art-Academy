AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Persistence = Artificial.Mummification.Document.Persistence

# Adventure overrides for stand-alone learn mode builds.
class LM.Adventure extends LM.Adventure
  @rootUrl: -> '/'

  getLocalSyncedStorage: ->
    if Meteor.isDesktop
      new Persistence.SyncedStorages.FileSystem
        relativeDirectoryPath: 'saves'
        relativeBackupDirectoryPath: 'save backups'

    else
      super arguments...
  
  endRun: ->
    if AB.ApplicationEnvironment.isElectron
      # Override to not perform any database flush behaviors since we don't
      # know if the OS will give us the time to perform the saves in time.
      return
    
    super arguments...
