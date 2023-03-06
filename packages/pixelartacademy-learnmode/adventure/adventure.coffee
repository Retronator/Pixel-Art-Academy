AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Persistence = Artificial.Mummification.Document.Persistence

# Adventure overrides for stand-alone learn mode builds.
class PAA.LearnMode.Adventure extends PAA.LearnMode.Adventure
  getLocalSyncedStorage: -> # TODO: Provide file-system storage
