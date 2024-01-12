LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.PixelCanvas.Cursor
  @Types =
    AliasedBrush: 'AliasedBrush'
    AntiAliasedBrush: 'AntiAliasedBrush'
    Pixel: 'Pixel'
  
  constructor: (@pixelCanvas) ->
    @brushHelper = @pixelCanvas.interface.getHelper LOI.Assets.SpriteEditor.Helpers.Brush
    
    @type = new ComputedField =>
      toolType = @pixelCanvas.interface.activeTool()?.cursorType?()
      toolType or @constructor.Types.Pixel

    @cursorPosition = new ComputedField =>
      return unless canvasCoordinates = @pixelCanvas.pointer()?.canvasCoordinate()
      return unless camera = @pixelCanvas.camera()
      
      type = @type()
  
      if type is @constructor.Types.AntiAliasedBrush
        {centerCoordinates: canvasCoordinates}
        
      else if type is @constructor.Types.AliasedBrush
  
        aliasedSize = @brushHelper.aliasedSize()
        center = aliasedSize / 2
  
        topLeftCoordinates =
          x: Math.round canvasCoordinates.x - center
          y: Math.round canvasCoordinates.y - center
  
        centerOffset = Math.floor (aliasedSize - 1) / 2
  
        centerCoordinates =
          x: topLeftCoordinates.x + centerOffset
          y: topLeftCoordinates.y + centerOffset
  
        pixelPerfectTopLeftCoordinates = camera.roundCanvasToWindowPixel topLeftCoordinates
  
        {centerCoordinates, centerOffset, pixelPerfectTopLeftCoordinates}
        
      else
        topLeftCoordinates =
          x: Math.floor canvasCoordinates.x
          y: Math.floor canvasCoordinates.y
          
        pixelPerfectTopLeftCoordinates = camera.roundCanvasToWindowPixel topLeftCoordinates
  
        {pixelPerfectTopLeftCoordinates}
    ,
      EJSON.equals

    @cursorArea = new ComputedField =>
      cursorArea =
        position: @cursorPosition()
      
      type = @type()
      
      if type is @constructor.Types.AntiAliasedBrush
        _.extend cursorArea,
          diameter: @brushHelper.diameter()
          round: @brushHelper.round()
      
      else if type is @constructor.Types.AliasedBrush
        _.extend cursorArea,
          aliasedShape: @brushHelper.aliasedShape()
  
      cursorArea

  drawToContext: (context) ->
    # Don't draw the cursor when the interface is inactive.
    return unless @pixelCanvas.interface.active()
    
    cursorArea = @cursorArea()
    return unless cursorArea.position
    position = cursorArea.position.pixelPerfectTopLeftCoordinates

    # Don't draw an out-of-bounds pixel brush
    type = @type()
    bounds = @pixelCanvas.assetData()?.bounds
    
    if type is @constructor.Types.Pixel and bounds?.fixed
      return unless bounds.left <= position.x <= bounds.right and bounds.top <= position.y <= bounds.bottom
  
    # Determine stroke style.
    scale = @pixelCanvas.camera().scale()
    effectiveScale = @pixelCanvas.camera().effectiveScale()
  
    pixelSize = 1 / effectiveScale
    context.lineWidth = pixelSize

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
      
      if type is @constructor.Types.AntiAliasedBrush
        if cursorArea.round
          # Draw the cursor as a circle.
          context.arc cursorArea.position.centerCoordinates.x, cursorArea.position.centerCoordinates.y, cursorArea.diameter / 2, 0, 2 * Math.PI
          
        else
          # Draw the cursor as a square.
          halfDiameter = cursorArea.diameter / 2
          context.rect cursorArea.position.centerCoordinates.x - halfDiameter, cursorArea.position.centerCoordinates.y - halfDiameter, cursorArea.diameter, cursorArea.diameter
        
      else if type is @constructor.Types.AliasedBrush and cursorArea.aliasedShape
        aliasedSize = cursorArea.aliasedShape.length
        position = cursorArea.position.pixelPerfectTopLeftCoordinates
    
        for x in [0..aliasedSize]
          for y in [0..aliasedSize]
            current = (cursorArea.aliasedShape[x]?[y] or false)
            # Look up to see if we should draw a horizontal line.
            unless current is (cursorArea.aliasedShape[x]?[y - 1] or false)
              context.moveTo position.x + x, position.y + y
              context.lineTo position.x + x + 1, position.y + y
    
            # Look left to see if we should draw a vertical line.
            unless current is (cursorArea.aliasedShape[x - 1]?[y] or false)
              context.moveTo position.x + x, position.y + y
              context.lineTo position.x + x, position.y + y + 1
              
      else
        # Draw the cursor as a single pixel.
        context.rect cursorArea.position.pixelPerfectTopLeftCoordinates.x, cursorArea.position.pixelPerfectTopLeftCoordinates.y, 1, 1
      
      context.stroke()
  
      # TODO: symmetryXOrigin = @pixelCanvas.options.symmetryXOrigin?()
      #
      # if symmetryXOrigin?
      #   mirroredX = -cursorArea.position.x + 2 * symmetryXOrigin
      #   context.strokeRect mirroredX, cursorArea.position.y, 1, 1

    context.setLineDash []
