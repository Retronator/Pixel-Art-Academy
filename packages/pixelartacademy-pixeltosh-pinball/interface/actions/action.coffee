FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.Action extends PAA.Pixeltosh.OS.Interface.Actions.Action
  constructor: ->
    super arguments...
    
    @pinball = @os.getProgram Pinball
