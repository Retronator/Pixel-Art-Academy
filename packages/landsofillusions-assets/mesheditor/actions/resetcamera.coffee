AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ResetCamera extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ResetCamera'
  @displayName: -> "Reset camera"

  @initialize()

  enabled: ->
    # We can reset the camera when we have an active camera angle.
    editor = @interface.getEditorForActiveFile()
    editor.cameraAngle()

  execute: ->
    # Reset the camera offset.
    editor = @interface.getEditorForActiveFile()
    editor.renderer.cameraManager.reset()
