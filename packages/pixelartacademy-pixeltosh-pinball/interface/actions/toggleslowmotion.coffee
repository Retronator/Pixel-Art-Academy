AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.ToggleSlowMotion extends Pinball.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.ToggleSlowMotion'
  @displayName: -> "Slow motion"

  @initialize()
  
  enabled: -> true
  
  active: -> @pinball.slowMotion()
  
  execute: ->
    @pinball.slowMotion not @pinball.slowMotion()
