AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Actions.Restart extends PAA.Pixeltosh.OS.Interface.Actions.Action
  @id: -> "PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Actions.Restart"
  
  @displayName: -> "Restart"
  
  @initialize()
  
  enabled: ->
    game = @interface.getView DrawQuickly.Interface.Game
    game.currentScreen() in [DrawQuickly.Interface.Game.ScreenTypes.Draw, DrawQuickly.Interface.Game.ScreenTypes.Results]
  
  execute: ->
    game = @interface.getView DrawQuickly.Interface.Game
    game.showInstructions()
