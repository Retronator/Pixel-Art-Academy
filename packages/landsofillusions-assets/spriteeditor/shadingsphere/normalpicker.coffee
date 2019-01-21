AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.ShadingSphere.NormalPicker extends LOI.Assets.Components.Tool
  onMouseDown: (event) ->
    super arguments...

    @calculateNormal()

  onMouseMove: (event) ->
    super arguments...

    @calculateNormal()

  calculateNormal: ->
    return unless @mouseState.leftButton

    shadingSphere = @options.editor()

    keyboardState = AC.Keyboard.getState()
    editLight = shadingSphere.editLight() or keyboardState.isKeyDown AC.Keys.shift

    canvasCoordinate = shadingSphere.pixelCanvas().mouse().canvasCoordinate()

    # Snap to angle when choosing a normal, but not for changing light.
    angleSnap = shadingSphere.angleSnap() unless editLight

    # Set the new normal.
    normal = shadingSphere.canvasCoordinateToNormal canvasCoordinate, angleSnap

    if editLight
      # Set light direction to the inverse of the normal
      shadingSphere.lightDirectionHelper() THREE.Vector3.fromObject(normal).negate()

    else
      shadingSphere.setNormal normal
