FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Actions.Action extends PAA.Pixeltosh.OS.Interface.Actions.Action
  constructor: ->
    super arguments...
    
    @chess = @os.getProgram Chess
