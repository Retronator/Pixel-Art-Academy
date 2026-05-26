AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Actions.BackToMenu extends Chess.Interface.Actions.Action
  @id: -> "PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.BackToMenu"
  @displayName: -> "Back to Menu"
  
  @initialize()
  
  enabled: -> not @chess.interfaceManager()?.inMenu()
  
  execute: ->
    @chess.interfaceManager().enterScreen Chess.InterfaceManager.Screens.Menu
