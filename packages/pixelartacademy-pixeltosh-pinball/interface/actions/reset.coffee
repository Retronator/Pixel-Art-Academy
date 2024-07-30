AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.Reset extends Pinball.Interface.Actions.Action
  @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.Reset"
  
  @displayName: -> "Reset"
  
  @initialize()
  
  enabled: -> @pinball.gameManager()?.mode() in [Pinball.GameManager.Modes.Test, Pinball.GameManager.Modes.Play]
  
  execute: ->
    @pinball.gameManager().reset()
