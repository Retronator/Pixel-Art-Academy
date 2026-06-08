AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard.Component extends AM.Component
  onCreated: ->
    super arguments...
    
    @interface = @ancestorComponentOfType FM.Interface
    @os = @interface.parent
    @chess = @os.getProgram Chess
