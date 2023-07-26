LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.PixelCanvas.Cursor
  constructor: (@pixelCanvas) ->
    @brushHelper = @pixelCanvas.interface.getHelper LOI.Assets.SpriteEditor.Helpers.Brush

    @cursorPosition = new ComputedField =>
      canvasCoordinates = @pixelCanvas.mouse()?.canvasCoordinate()
      return unless canvasCoordinates

      camera = @pixelCanvas.camera()
      return unless camera

      size = @brushHelper.shape().length
      center = size / 2

      topLeftCoordinates =
        x: Math.round canvasCoordinates.x - center
        y: Math.round canvasCoordinates.y - center

      centerOffset = Math.floor (size - 1) / 2

      centerCoordinates =
        x: topLeftCoordinates.x + centerOffset
        y: topLeftCoordinates.y + centerOffset

      pixelPerfectTopLeftCoordinates = camera.roundCanvasToWindowPixel topLeftCoordinates

      {centerCoordinates, centerOffset, pixelPerfectTopLeftCoordinates}
    ,
      EJSON.equals

    @cursorArea = new ComputedField =>
      position: @cursorPosition()
      shape: @brushHelper.shape()

  drawToContext: (context) ->
    # Don't draw the cursor when the interface is inactive.
    return unless @pixelCanvas.interface.active()
    
    scale = @pixelCanvas.camera().scale()
    effectiveScale = @pixelCanvas.camera().effectiveScale()
    cursorArea = @cursorArea()
    return unless cursorArea.position
  
    pixelSize = 1 / effectiveScale
    context.lineWidth = pixelSize

    size = cursorArea.shape.length
    position = cursorArea.position.pixelPerfectTopLeftCoordinates

    for step in [1..2]
      if scale > 4
        # Alternate between black and white dashes.
        context.strokeStyle = if step is 1 then 'rgba(255,255,255,0.3)' else 'rgba(0,0,0,0.3)'
        context.setLineDash [2 / scale]
        context.lineDashOffset = step * 2 / scale
      
      else
        # The small scale cursor doesn't have two dashed colors.
        break if step is 2

        context.strokeStyle = 'rgba(128,128,128,0.5)'
        context.setLineDash []
      
      context.beginPath()
  
      for x in [0..size]
        for y in [0..size]
          current = (cursorArea.shape[x]?[y] or false)
          # Look up to see if we should draw a horizontal line.
          unless current is (cursorArea.shape[x]?[y - 1] or false)
            context.moveTo position.x + x, position.y + y
            context.lineTo position.x + x + 1, position.y + y
  
          # Look left to see if we should draw a vertical line.
          unless current is (cursorArea.shape[x - 1]?[y] or false)
            context.moveTo position.x + x, position.y + y
            context.lineTo position.x + x, position.y + y + 1
  
      context.stroke()
  
      # TODO: symmetryXOrigin = @pixelCanvas.options.symmetryXOrigin?()
      #
      # if symmetryXOrigin?
      #   mirroredX = -cursorArea.position.x + 2 * symmetryXOrigin
      #   context.strokeRect mirroredX, cursorArea.position.y, 1, 1
