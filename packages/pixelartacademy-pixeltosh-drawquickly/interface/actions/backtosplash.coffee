AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Actions.BackToSplash extends PAA.Pixeltosh.OS.Interface.Actions.Action
  @id: -> "PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Actions.BackToSplash"
  
  @displayName: -> "End"
  
  @initialize()
  
  enabled: ->
    game = @interface.getView DrawQuickly.Interface.Game
    game.currentScreen() is DrawQuickly.Interface.Game.ScreenTypes.Draw
  
  execute: ->
    game = @interface.getView DrawQuickly.Interface.Game
    game.backToSplash()
