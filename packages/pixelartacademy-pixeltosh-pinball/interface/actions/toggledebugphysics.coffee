AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.ToggleDebugPhysics extends Pinball.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.ToggleDebugPhysics'
  @displayName: -> "Debug physics"

  @initialize()
  
  enabled: -> true
  
  active: -> @pinball.debugPhysics()
  
  execute: ->
    @pinball.debugPhysics not @pinball.debugPhysics()
