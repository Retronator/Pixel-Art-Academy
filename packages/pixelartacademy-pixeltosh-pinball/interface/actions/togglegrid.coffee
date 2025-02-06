AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.ToggleGrid extends Pinball.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.ToggleGrid'
  @displayName: -> "Grid"

  @initialize()
  
  enabled: -> not @pinball.gameManager()?.inPlay()
  
  active: -> @pinball.showGrid()
  
  execute: ->
    @pinball.showGrid not @pinball.showGrid()
