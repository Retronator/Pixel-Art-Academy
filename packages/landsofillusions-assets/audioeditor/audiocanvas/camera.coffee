AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.AudioCanvas.Camera
  constructor: (@audioCanvas) ->
    # At camera scale 1, a canvas pixel matches a display pixel (and not window pixel).
    # Scale is used to go from canvas pixels to display pixels.
    @scale = new ReactiveField 1

    # Effective scale includes the amount we're scaling our display pixels.
    # It is used to go from canvas pixels to window pixels.
    @effectiveScale = new ComputedField =>
      displayScale = @audioCanvas.display.scale()
      @scale() * displayScale

    # Origin tells which coordinate is at the center of the canvas.
    @origin = new ReactiveField x: 0, y: 0

    @_preciseOrigin = @origin()

    # Calculate viewport in canvas coordinates.
    @viewportBounds = new AE.Rectangle()

    @audioCanvas.autorun =>
      effectiveScale = @effectiveScale()
      origin = @origin()

      # Calculate which part of the canvas is visible. Canvas bounds is in window pixels.
      width = @audioCanvas.bounds.width() / effectiveScale
      height = @audioCanvas.bounds.height() / effectiveScale

      @viewportBounds.width width
      @viewportBounds.height height
      @viewportBounds.x origin.x - width / 2
      @viewportBounds.y origin.y - height / 2

    # Enable panning with scrolling.

    # Wire up mouse wheel event once the sprite editor is rendered.
    @audioCanvas.autorun (computation) =>
      $audioCanvas = @audioCanvas.$audioCanvas()
      return unless $audioCanvas
      computation.stop()

      $audioCanvas.on 'wheel', (event) =>
        event.preventDefault()

        effectiveScale = @effectiveScale()

        windowDelta =
          x: event.originalEvent.deltaX
          y: event.originalEvent.deltaY

        canvasDelta =
          x: windowDelta.x / effectiveScale
          y: windowDelta.y / effectiveScale

        @setOrigin
          x: @_preciseOrigin.x + canvasDelta.x
          y: @_preciseOrigin.y + canvasDelta.y

  setOrigin: (origin) ->
    @_preciseOrigin = origin

    @origin
      x: Math.floor @_preciseOrigin.x
      y: Math.floor @_preciseOrigin.y

  applyTransformToCanvas: ->
    context = @audioCanvas.context()
    effectiveScale = @effectiveScale()
    origin = @origin()

    # Start from the identity.
    context.setTransform 1, 0, 0, 1, 0, 0

    # Move to center of screen.
    width = @audioCanvas.bounds.width()
    height = @audioCanvas.bounds.height()
    context.translate width / 2, height / 2

    # Scale the canvas around the origin.
    context.scale effectiveScale, effectiveScale

    # Move to origin.
    context.translate -origin.x, -origin.y

  transformCanvasToWindow: (canvasCoordinate) ->
    effectiveScale = @effectiveScale()
    origin = @origin()

    x = canvasCoordinate.x
    y = canvasCoordinate.y
    width = @audioCanvas.bounds.width()
    height = @audioCanvas.bounds.height()

    x: (x - origin.x) * effectiveScale + width / 2
    y: (y - origin.y) * effectiveScale + height / 2

  transformCanvasToDisplay: (canvasCoordinate) ->
    windowCoordinate = @transformCanvasToWindow canvasCoordinate
    displayScale = @audioCanvas.display.scale()

    x: windowCoordinate.x / displayScale
    y: windowCoordinate.y / displayScale

  transformWindowToCanvas: (windowCoordinate) ->
    effectiveScale = @effectiveScale()
    origin = @origin()

    x = windowCoordinate.x
    y = windowCoordinate.y
    width = @audioCanvas.bounds.width()
    height = @audioCanvas.bounds.height()

    x: (x - width / 2) / effectiveScale + origin.x
    y: (y - height / 2) / effectiveScale + origin.y

  transformDisplayToCanvas: (displayCoordinate) ->
    displayScale = @audioCanvas.display.scale()

    windowCoordinate =
      x: displayCoordinate.x * displayScale
      y: displayCoordinate.y * displayScale

    @transformWindowToCanvas windowCoordinate

  roundCanvasToWindowPixel: (canvasCoordinate, lineWidth = 1) ->
    windowCoordinate = @transformCanvasToWindow canvasCoordinate
    pixelPerfectWindowCoordinate =
      x: Math.floor(windowCoordinate.x) + lineWidth / 2
      y: Math.floor(windowCoordinate.y) + lineWidth / 2

    @transformWindowToCanvas pixelPerfectWindowCoordinate
