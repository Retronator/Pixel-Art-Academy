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

    canvasCoordinate = @options.editor().pixelCanvas().mouse().canvasCoordinate()

    # Set the new normal.
    normal = @options.editor().canvasCoordinateToNormal canvasCoordinate

    if @options.editor().editLight()
      # Set light direction to the inverse of the normal
      @options.editor().options.lightDirection THREE.Vector3.fromObject(normal).negate()

    else
      @options.editor().setNormal normal
