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
  
  enabled: -> @pinball.editorManager()?.selectedPart()
  
  execute: ->
    editorManager = @pinball.editorManager()
    selectedPart = editorManager.selectedPart()
    flipped = selectedPart.data().flipped
    position = _.clone selectedPart.position()
    bitmap = selectedPart.bitmap()
    shape = selectedPart.shape()
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    originOffset = -(bitmap.bounds.width / 2 - shape.bitmapOrigin.x) * pixelSize
    originOffset *= -1 if flipped
    
    position.x -= 2 * originOffset
    Pinball.CameraManager.snapShapeToPixelPosition shape, position

    editorManager.updateSelectedPart
      flipped: not flipped
      position: position
