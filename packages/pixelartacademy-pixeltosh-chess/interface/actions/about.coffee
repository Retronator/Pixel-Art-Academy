AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Actions.About extends Chess.Interface.Actions.Action
  @id: -> "PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.About"
  
  @displayName: -> "About Chess Academy .."
  
  @initialize()
  
  execute: ->
    @os.interface.displayDialog Chess.Interface.About.createInterfaceData()
