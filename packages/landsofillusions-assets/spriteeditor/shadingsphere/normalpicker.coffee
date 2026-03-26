AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.ShadingSphere.NormalPicker extends LOI.Assets.Components.Tools.Tool
  onPointerDown: (event) ->
    super arguments...

    @calculateNormal()

  onPointerMove: (event) ->
    super arguments...

    @calculateNormal()

  calculateNormal: ->
    return unless @constructor.pointerState.mainButton

    shadingSphere = @options.editor()

    keyboardState = AC.Keyboard.getState()
    editLight = shadingSphere.editLight() or keyboardState.isKeyDown AC.Keys.shift

    canvasCoordinate = shadingSphere.pixelCanvas().pointer().canvasCoordinate()

    # Snap to angle when choosing a normal, but not for changing light.
    angleSnap = shadingSphere.angleSnap() unless editLight

    # Set the new normal.
    normal = shadingSphere.canvasCoordinateToNormal canvasCoordinate, angleSnap

    # Pick on the other side of the sphere with alt.
    normal.z *= -1 if keyboardState.isKeyDown AC.Keys.alt

    if editLight
      # Set light direction to the inverse of the normal
      shadingSphere.lightDirectionHelper() THREE.Vector3.fromObject(normal).negate()

    else
      shadingSphere.setNormal normal
