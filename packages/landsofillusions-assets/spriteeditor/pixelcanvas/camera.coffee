AC = Artificial.Control
AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.PixelCanvas.Camera
  constructor: (@pixelCanvas, options) ->
    @cameraData = new ComputedField =>
      @pixelCanvas.interface.getActiveFileData()?.child 'camera'

    @scaleData = new ComputedField =>
      @cameraData()?.child 'scale'

    # At camera scale 1, a canvas pixel matches a display pixel (and not window pixel).
    # Scale is used to go from canvas pixels to display pixels.
    @scale = new ComputedField =>
      @scaleData()?.value() or @pixelCanvas.initialCameraScale() or 1

    # Effective scale includes the amount we're scaling our display pixels.
    # It is used to go from canvas pixels to window pixels.
    @effectiveScale = new ComputedField =>
      displayScale = @pixelCanvas.display.scale()
      @scale() * displayScale

    @scrollingEnabled = new ComputedField =>
      @pixelCanvas.scrollingEnabled()
      
    @originData = new ComputedField =>
      @cameraData()?.child 'origin'

    @origin = new ComputedField =>
      @originData()?.value() or x: 0, y: 0
    ,
      EJSON.equals

    # Calculate various bounds. Canvas bounds are relative to the asset origin.
    @assetCanvasBounds = new AE.Rectangle()
    @drawingAreaCanvasBounds = new AE.Rectangle()
    @renderableAreaCanvasBounds = new AE.Rectangle()
    @viewportCanvasBounds = new AE.Rectangle()
    
    # Window bounds are relative to the center of the pixel canvas.
    @drawingAreaWindowBounds = new AE.Rectangle()
    @canvasWindowBounds = new AE.Rectangle()

    @pixelCanvas.autorun =>
      # Asset bounds are directly copied from the asset.
      return unless assetData = @pixelCanvas.assetData()
      
      @assetCanvasBounds.copy assetData.bounds
     
      # Calculate drawing area bounds in canvas coordinates.
      displayMode = @pixelCanvas.displayMode()
      
      if assetData.bounds.fixed or displayMode is LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Full
        # When the asset bounds are fixed, or if we're drawing the full canvas, the drawing area matches it directly.
        @drawingAreaCanvasBounds.copy assetData.bounds
      
      else if displayMode is LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Framed
        # When the asset bounds are freeform and we need to frame the drawing, we make the drawing area 50% bigger than the existing asset bounds.
        verticalFreeformBorder = (assetData.bounds?.width or 128) * 0.25
        horizontalFreeformBorder = (assetData.bounds?.height or 128) * 0.25
        
        @drawingAreaCanvasBounds.copy(assetData.bounds).extrude verticalFreeformBorder, horizontalFreeformBorder
        
      else
        # Without the frame, the drawing area extends into infinity.
        @drawingAreaCanvasBounds.left Number.NEGATIVE_INFINITY
        @drawingAreaCanvasBounds.top Number.NEGATIVE_INFINITY
        @drawingAreaCanvasBounds.right Number.POSITIVE_INFINITY
        @drawingAreaCanvasBounds.bottom Number.POSITIVE_INFINITY
        
      if displayMode is LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Full
        # When the full canvas is rendered, pixel canvas is assumed to fully cover it.
        @renderableAreaCanvasBounds.copy assetData.bounds
      
      else
        # Renderable area is twice the pixel canvas to prevent the canvas being cut-off during transitions.
        pixelCanvasWindowSize = @pixelCanvas.windowSize()
        effectiveScale = @effectiveScale()
        width = pixelCanvasWindowSize.width / effectiveScale
        height = pixelCanvasWindowSize.height / effectiveScale
        origin = @origin()
    
        @renderableAreaCanvasBounds.width width * 2
        @renderableAreaCanvasBounds.height height * 2
        @renderableAreaCanvasBounds.x origin.x - width
        @renderableAreaCanvasBounds.y origin.y - height

      # Viewport bounds are the intersection of the pixel canvas bounds and the drawing area bounds.
      @viewportCanvasBounds.copy(@renderableAreaCanvasBounds).intersect @drawingAreaCanvasBounds
    
      if displayMode is LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Full
        effectiveScale = @effectiveScale()
        @drawingAreaWindowBounds.x 0
        @drawingAreaWindowBounds.y 0
        @drawingAreaWindowBounds.width assetData.bounds.width * effectiveScale
        @drawingAreaWindowBounds.height assetData.bounds.height * effectiveScale
  
        @canvasWindowBounds.copy @drawingAreaWindowBounds
        
      else
        # Calculate the bounds of the drawing area in window coordinates relative to the pixel canvas center.
        drawingAreaTopLeft = @transformCanvasToWindowCenter x: @drawingAreaCanvasBounds.left(), y: @drawingAreaCanvasBounds.top()
        drawingAreaBottomRight = @transformCanvasToWindowCenter x: @drawingAreaCanvasBounds.right(), y: @drawingAreaCanvasBounds.bottom()
        
        @drawingAreaWindowBounds.copy
          left: drawingAreaTopLeft.x
          top: drawingAreaTopLeft.y
          right: drawingAreaBottomRight.x
          bottom: drawingAreaBottomRight.y
    
        # Calculate the bounds of the canvas in window coordinates relative to the drawing area top left corner.
        canvasTopLeft = @transformCanvasToWindowCenter x: @viewportCanvasBounds.left(), y: @viewportCanvasBounds.top()
        canvasBottomRight = @transformCanvasToWindowCenter x: @viewportCanvasBounds.right(), y: @viewportCanvasBounds.bottom()

        # Fit the transformed coordinates and add extra padding to the size for the outer grid line.
        @canvasWindowBounds.copy
          left: canvasTopLeft.x
          top: canvasTopLeft.y
          width: Math.floor(canvasBottomRight.x) - Math.floor(canvasTopLeft.x) + 1
          height: Math.floor(canvasBottomRight.y) - Math.floor(canvasTopLeft.y) + 1
          
    # Enable panning with scrolling.
    @pixelCanvas.autorun (computation) =>
      # Wire up mouse wheel event once the sprite editor is rendered.
      $parent = options.$parent()
      return unless $parent

      scrollingEnabled = @scrollingEnabled()
      
      if scrollingEnabled and not @_scrollingFunction
        # Enable the wheel event.
        @_scrollingFunction = (event) => @_onWheel event
        $parent.on 'wheel', @_scrollingFunction
        
      else if @_scrollingFunction and not scrollingEnabled
        # Disable the wheel event.
        $parent.off 'wheel', @_scrollingFunction
    
  _onWheel: (event) ->
    event.preventDefault()

    effectiveScale = @effectiveScale()

    if event.ctrlKey
      # User is zooming in/out.
      delta = event.originalEvent.deltaY

      scale = @scale()
      scaleChange = Math.pow(0.99, delta)

      @setScale scale * scaleChange

      # Also move the origin, depending on how much off-center we were zooming.
      canvasOrigin = $parent.offset()

      mouseWindowCoordinate =
        x: event.originalEvent.pageX - canvasOrigin.left
        y: event.originalEvent.pageY - canvasOrigin.top

      mouseCanvasCoordinate = @transformWindowToCanvas mouseWindowCoordinate

      oldOrigin = @origin()

      offCenter =
        x: mouseCanvasCoordinate.x - oldOrigin.x
        y: mouseCanvasCoordinate.y - oldOrigin.y

      @originData().value
        x: oldOrigin.x + offCenter.x * (scaleChange - 1)
        y: oldOrigin.y + offCenter.y * (scaleChange - 1)

    else
      # User is translating.

      windowDelta =
        x: event.originalEvent.deltaX
        y: event.originalEvent.deltaY

      canvasDelta =
        x: windowDelta.x / effectiveScale
        y: windowDelta.y / effectiveScale

      oldOrigin = @origin()

      @originData().value
        x: oldOrigin.x + canvasDelta.x
        y: oldOrigin.y + canvasDelta.y

  setScale: (scale) ->
    @scaleData().value scale

  setOrigin: (origin) ->
    @originData().value origin

  applyTransformToCanvas: ->
    context = @pixelCanvas.context()
    effectiveScale = @effectiveScale()
    canvasScale = effectiveScale * devicePixelRatio

    # Start from the identity.
    context.setTransform 1, 0, 0, 1, 0, 0

    # Scale the canvas around the origin.
    context.scale canvasScale, canvasScale

    # Move to viewport corner.
    translateX = @viewportCanvasBounds.x()
    translateY = @viewportCanvasBounds.y()
    context.translate -translateX, -translateY

  transformCanvasToWindowCenter: (canvasCoordinate) ->
    effectiveScale = @effectiveScale()
    origin = @origin()
  
    x = canvasCoordinate.x
    y = canvasCoordinate.y
  
    x: (x - origin.x) * effectiveScale
    y: (y - origin.y) * effectiveScale
    
  transformCanvasToWindow: (canvasCoordinate) ->
    windowCoordinateCenter = @transformCanvasToWindowCenter canvasCoordinate
  
    pixelCanvasWindowSize = @pixelCanvas.windowSize()
    width = pixelCanvasWindowSize.width
    height = pixelCanvasWindowSize.height
    
    windowCoordinateCenter.x += width / 2
    windowCoordinateCenter.y += height / 2
  
    windowCoordinateCenter

  transformCanvasToDisplay: (canvasCoordinate) ->
    windowCoordinate = @transformCanvasToWindow canvasCoordinate
    displayScale = @pixelCanvas.display.scale()

    x: windowCoordinate.x / displayScale
    y: windowCoordinate.y / displayScale

  transformWindowToCanvas: (windowCoordinate) ->
    pixelCanvasWindowSize = @pixelCanvas.windowSize()

    x = windowCoordinate.x - pixelCanvasWindowSize.width / 2
    y = windowCoordinate.y - pixelCanvasWindowSize.height / 2
    
    @transformWindowCenterToCanvas {x, y}
  
  transformWindowCenterToCanvas: (windowCoordinate) ->
    effectiveScale = @effectiveScale()
    origin = @origin()
    
    x = windowCoordinate.x
    y = windowCoordinate.y
    
    x: x / effectiveScale + origin.x
    y: y / effectiveScale + origin.y

  transformDisplayToCanvas: (displayCoordinate) ->
    displayScale = @pixelCanvas.display.scale()

    windowCoordinate =
      x: displayCoordinate.x * displayScale
      y: displayCoordinate.y * displayScale

    @transformWindowToCanvas windowCoordinate

  roundCanvasToWindowPixel: (canvasCoordinate) ->
    windowCoordinate = @transformCanvasToWindowCenter canvasCoordinate
    
    # Transform to corner of the canvas.
    canvasX = @canvasWindowBounds.x()
    canvasY = @canvasWindowBounds.y()
    windowCoordinate.x -= canvasX
    windowCoordinate.y -= canvasY
    
    # Move to the center of the pixel.
    windowCoordinate.x = Math.floor(windowCoordinate.x) + 0.5
    windowCoordinate.y = Math.floor(windowCoordinate.y) + 0.5
    
    # Transform back to window center.
    windowCoordinate.x += canvasX
    windowCoordinate.y += canvasY

    @transformWindowCenterToCanvas windowCoordinate

  debugOutput: ->
    console.log "PIXEL CANVAS CAMERA"
    console.log "scale:", @scale()
    console.log "origin:", @origin()
    
    console.log "asset canvas bounds", @assetCanvasBounds.toDimensions()
    console.log "drawing area canvas bounds", @drawingAreaCanvasBounds.toDimensions()
    console.log "renderable area canvas bounds", @renderableAreaCanvasBounds.toDimensions()
    console.log "viewport canvas bounds", @viewportCanvasBounds.toDimensions()
    
    console.log "drawing area window bounds", @drawingAreaWindowBounds.toDimensions()
    console.log "canvas window bounds", @canvasWindowBounds.toDimensions()
