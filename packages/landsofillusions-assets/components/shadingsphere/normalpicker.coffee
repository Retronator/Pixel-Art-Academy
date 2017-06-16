LOI = LandsOfIllusions

class LOI.Assets.Components.ShadingSphere.NormalPicker extends LandsOfIllusions.Assets.Tools.Tool
  onMouseDown: (event) ->
    super

    @calculateNormal()

  onMouseMove: (event) ->
    super

    @calculateNormal()

  calculateNormal: ->
    return unless @mouseState.leftButton

    editLight = @options.editor().editLight()

    canvasCoordinate = @options.editor().pixelCanvas().mouse().canvasCoordinate()

    # Snap to angle when choosing a normal, but not for changing light.
    angleSnap = @options.editor().options.angleSnap?() unless editLight

    # Set the new normal.
    normal = @options.editor().canvasCoordinateToNormal canvasCoordinate, angleSnap

    if @options.editor().editLight()
      # Set light direction to the inverse of the normal
      @options.editor().options.lightDirection THREE.Vector3.fromObject(normal).negate()

    else
      @options.editor().setNormal normal
