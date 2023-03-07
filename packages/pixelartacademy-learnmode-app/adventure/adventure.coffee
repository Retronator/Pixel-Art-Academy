AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

# Adventure overrides for stand-alone learn mode builds.
class LM.Adventure extends LM.Adventure
  @rootUrl: -> '/'
  
  # getLocalSyncedStorage: -> super arguments... TODO: Provide file-system storage
