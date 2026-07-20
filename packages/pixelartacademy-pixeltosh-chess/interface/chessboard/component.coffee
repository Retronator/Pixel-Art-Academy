AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard.Component extends AM.Component
  onCreated: ->
    super arguments...
    
    @interface = @ancestorComponentOfType FM.Interface
    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @chess = @os.getProgram Chess
