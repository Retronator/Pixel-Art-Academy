AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.Flip extends Pinball.Interface.Actions.Action
  @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.Flip"
  
  @displayName: -> "Flip"
  
  @initialize()
  
  enabled: -> @pinball.editorManager()?.selectedPart()?.constructor.placeable()
  
  execute: ->
    editorManager = @pinball.editorManager()
    selectedPart = editorManager.selectedPart()
    flipped = selectedPart.data().flipped
    rotationAngle = selectedPart.rotationAngle()

    editorManager.updateSelectedPart
      flipped: not flipped
      rotationAngle: -rotationAngle
