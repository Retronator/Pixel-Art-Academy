LOI = LandsOfIllusions

class LOI.Assets.Components.ShadingSphere.NormalPicker extends LandsOfIllusions.Assets.Tools.Tool
  onMouseDown: (event) ->
    super arguments...

    @calculateNormal()

  onMouseMove: (event) ->
    super arguments...

    @calculateNormal()

  calculateNormal: ->
    return unless @mouseState.leftButton

    shadingSphere = @options.editor()

    editLight = shadingSphere.editLight()

    canvasCoordinate = shadingSphere.pixelCanvas().mouse().canvasCoordinate()

    # Snap to angle when choosing a normal, but not for changing light.
    angleSnap = shadingSphere.angleSnap() unless editLight

    # Set the new normal.
    normal = shadingSphere.canvasCoordinateToNormal canvasCoordinate, angleSnap

    if shadingSphere.editLight()
      # Set light direction to the inverse of the normal
      shadingSphere.options.lightDirection THREE.Vector3.fromObject(normal).negate()

    else
      shadingSphere.setNormal normal
