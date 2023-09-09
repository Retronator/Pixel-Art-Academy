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
      new Persistence.SyncedStorages.FileSystem relativeDirectoryPath: 'saves'

    else
      super arguments...
