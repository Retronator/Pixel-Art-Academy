AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Rotate extends Pinball.Interface.Actions.Action
  @rotationAmount = Math.PI / 2 # 90 degrees
  
  @sign: -> throw new AE.NotImplementedException "Rotate action has to specify the sign of rotation."
  
  enabled: -> @pinball.editorManager()?.selectedPart()?.constructor.placeable()
  
  execute: ->
    editorManager = @pinball.editorManager()
    selectedPart = editorManager.selectedPart()
    rotationAngle = selectedPart.rotationAngle()
    
    newRotationAngle = rotationAngle + @constructor.rotationAmount * @constructor.sign()

    newPosition = _.clone selectedPart.position()
    rotationQuaternion = new THREE.Quaternion().setFromEuler new THREE.Euler 0, newRotationAngle, 0
    Pinball.CameraManager.snapShapeToPixelPosition selectedPart.shape(), newPosition, rotationQuaternion
    
    editorManager.updateSelectedPart
      rotationAngle: newRotationAngle
      position: newPosition

class Pinball.Interface.Actions.RotateClockwise extends Rotate
  @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.RotateClockwise"
  
  @displayName: -> "Rotate clockwise"
  
  @sign: -> -1
  
  @initialize()

class Pinball.Interface.Actions.RotateCounterClockwise extends Rotate
  @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.RotateCounterClockwise"
  
  @displayName: -> "Rotate counter-clockwise"
  
  @sign: -> 1
  
  @initialize()
