AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.ToggleDisplayWalls extends Pinball.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.ToggleDisplayWalls'
  @displayName: -> "Display walls"

  @initialize()
  
  enabled: -> not @pinball.gameManager()?.inPlay()
  
  active: -> @pinball.displayWalls()
  
  execute: ->
    @pinball.displayWalls not @pinball.displayWalls()
