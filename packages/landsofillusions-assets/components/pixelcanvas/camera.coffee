AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Components.PixelCanvas.Camera
  constructor: (@pixelCanvas, @options = {}) ->
    _.defaults @options,
      enableInput: true

    @cameraData = new ComputedField =>
      @pixelCanvas.componentFileData()?.child 'camera'

    @scaleData = new ComputedField =>
      @cameraData()?.child 'scale'

    # At camera scale 1, a canvas pixel matches a display pixel (and not window pixel).
    # Scale is used to go from canvas pixels to display pixels.
    @scale = new ComputedField =>
      @scaleData()?.value() or @pixelCanvas.componentData().get('initialCameraScale') or 1

    # Effective scale includes the amount we're scaling our display pixels.
    # It is used to go from canvas pixels to window pixels.
    @effectiveScale = new ComputedField =>
      displayScale = @pixelCanvas.display.scale()
      @scale() * displayScale

    @originData = new ComputedField =>
      @cameraData()?.child 'origin'

    @origin = new ComputedField =>
      @originData()?.value() or @pixelCanvas.componentData().get('initialCameraOrigin') or x:0, y:0
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
    if @options.enableInput
      @pixelCanvas.autorun (computation) =>
        $pixelCanvas = @pixelCanvas.$pixelCanvas()
        return unless $pixelCanvas
        computation.stop()

        $pixelCanvas.on 'wheel', (event) =>
          event.preventDefault()

          effectiveScale = @effectiveScale()

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
    context.translate width / 2, height / 2

    # Scale the canvas around the origin.
    context.scale effectiveScale, effectiveScale

    # Move to origin.
    context.translate -origin.x, -origin.y

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
