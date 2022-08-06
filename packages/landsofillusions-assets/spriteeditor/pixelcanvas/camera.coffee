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
  
    @scrollingEnabledData = new ComputedField =>
      @cameraData()?.child 'scrollingEnabled'
  
    @scrollingEnabled = new ComputedField =>
      @scrollingEnabledData()?.value()
      
    @originData = new ComputedField =>
      @cameraData()?.child 'origin'

    @origin = new ComputedField =>
      if @scrollingEnabled()
        origin = @originData()?.value()
        
      else
        # When we can't scroll, we should show the center of the image.
        if bounds = @pixelCanvas.assetData()?.bounds
          origin =
            x: bounds.left + bounds.width / 2
            y: bounds.top + bounds.height / 2
  
      origin or @pixelCanvas.componentData.get('initialCameraOrigin') or x: 0, y: 0
    ,
      EJSON.equals

    # Calculate viewport in canvas coordinates.
    @viewportBounds = new AE.Rectangle()

    @pixelCanvas.autorun =>
      canvasPixelSize = @pixelCanvas.canvasPixelSize()
      effectiveScale = @effectiveScale()
      origin = @origin()

      # Calculate which part of the canvas is visible.
      width = canvasPixelSize.width / effectiveScale
      height = canvasPixelSize.height / effectiveScale

      @viewportBounds.width width
      @viewportBounds.height height
      @viewportBounds.x origin.x - width / 2
      @viewportBounds.y origin.y - height / 2

    # Enable panning with scrolling.

    # Wire up mouse wheel event once the sprite editor is rendered.
    @pixelCanvas.autorun (computation) =>
      $parent = options.$parent()
      return unless $parent
      computation.stop()
      
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
    canvasPixelSize = @pixelCanvas.canvasPixelSize()
    effectiveScale = @effectiveScale()
    origin = @origin()

    # Start from the identity.
    context.setTransform 1, 0, 0, 1, 0, 0

    # Move to center of screen.
    width = canvasPixelSize.width
    height = canvasPixelSize.height
    context.translate Math.floor(width / 2), Math.floor(height / 2)

    # Scale the canvas around the origin.
    context.scale effectiveScale, effectiveScale

    # Move to origin.
    translateX = Math.floor(origin.x * effectiveScale) / effectiveScale
    translateY = Math.floor(origin.y * effectiveScale) / effectiveScale
    context.translate -translateX, -translateY

  transformCanvasToWindow: (canvasCoordinate) ->
    canvasPixelSize = @pixelCanvas.canvasPixelSize()
    effectiveScale = @effectiveScale()
    origin = @origin()

    x = canvasCoordinate.x
    y = canvasCoordinate.y
    width = canvasPixelSize.width
    height = canvasPixelSize.height

    x: (x - origin.x) * effectiveScale + width / 2
    y: (y - origin.y) * effectiveScale + height / 2

  transformCanvasToDisplay: (canvasCoordinate) ->
    windowCoordinate = @transformCanvasToWindow canvasCoordinate
    displayScale = @pixelCanvas.display.scale()

    x: windowCoordinate.x / displayScale
    y: windowCoordinate.y / displayScale

  transformWindowToCanvas: (windowCoordinate) ->
    canvasPixelSize = @pixelCanvas.canvasPixelSize()
    effectiveScale = @effectiveScale()
    origin = @origin()

    x = windowCoordinate.x
    y = windowCoordinate.y
    width = canvasPixelSize.width
    height = canvasPixelSize.height

    x: (x - width / 2) / effectiveScale + origin.x
    y: (y - height / 2) / effectiveScale + origin.y

  transformDisplayToCanvas: (displayCoordinate) ->
    displayScale = @pixelCanvas.display.scale()

    windowCoordinate =
      x: displayCoordinate.x * displayScale
      y: displayCoordinate.y * displayScale

    @transformWindowToCanvas windowCoordinate

  roundCanvasToWindowPixel: (canvasCoordinate) ->
    windowCoordinate = @transformCanvasToWindow canvasCoordinate
    pixelPerfectWindowCoordinate =
      x: Math.floor(windowCoordinate.x) + 0.5
      y: Math.floor(windowCoordinate.y) + 0.5

    @transformWindowToCanvas pixelPerfectWindowCoordinate
