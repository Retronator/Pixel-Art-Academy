AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.StudyPlan.Canvas.Camera
  constructor: (@canvas) ->
    @state = new LOI.StateObject address: @canvas.studyPlan.stateAddress.child 'camera'
    
    # At camera scale 1, a canvas pixel matches a display pixel (and not window pixel).
    # Scale is used to go from canvas pixels to display pixels. We use lazy updates to minimize state reactivity.
    @scale = @state.field 'scale',
      equalityFunction: EJSON.equals
      lazyUpdates: true

    @scale 1 unless @scale()

    # Effective scale includes the amount we're scaling our display pixels.
    # It is used to go from canvas pixels to window pixels.
    @effectiveScale = new ComputedField =>
      displayScale = @canvas.display.scale()
      @scale() * displayScale

    # Origin tells which coordinate is at the center of the canvas. We use lazy updates to minimize state reactivity.
    @origin = @state.field 'origin',
      equalityFunction: EJSON.equals
      lazyUpdates: true

    @origin x: 0, y: 0 unless @origin()

    # Calculate viewport in canvas coordinates.
    @viewportBounds = new AE.Rectangle()

    @canvas.autorun =>
      effectiveScale = @effectiveScale()
      origin = @origin()

      # Calculate which part of the canvas is visible. Canvas bounds is in window pixels.
      width = @canvas.bounds.width() / effectiveScale
      height = @canvas.bounds.height() / effectiveScale

      @viewportBounds.width width
      @viewportBounds.height height
      @viewportBounds.x origin.x - width / 2
      @viewportBounds.y origin.y - height / 2

    # Enable panning with scrolling.

    # Wire up mouse wheel event once the sprite editor is rendered.
    @canvas.autorun (computation) =>
      $canvas = @canvas.$canvas()
      return unless $canvas
      computation.stop()

      $canvas.on 'wheel', (event) =>
        event.preventDefault()

        effectiveScale = @effectiveScale()

        windowDelta =
          x: event.originalEvent.deltaX
          y: event.originalEvent.deltaY

        canvasDelta =
          x: windowDelta.x / effectiveScale
          y: windowDelta.y / effectiveScale

        oldOrigin = @origin()

        @origin
          x: oldOrigin.x + canvasDelta.x
          y: oldOrigin.y + canvasDelta.y

  applyTransformToCanvas: ->
    context = @canvas.context()
    effectiveScale = @effectiveScale()
    origin = @origin()

    # Start from the identity.
    context.setTransform 1, 0, 0, 1, 0, 0

    # Move to center of screen.
    width = @canvas.bounds.width()
    height = @canvas.bounds.height()
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
    width = @canvas.bounds.width()
    height = @canvas.bounds.height()

    x: (x - origin.x) * effectiveScale + width / 2
    y: (y - origin.y) * effectiveScale + height / 2

  transformCanvasToDisplay: (canvasCoordinate) ->
    windowCoordinate = @transformCanvasToWindow canvasCoordinate
    displayScale = @canvas.display.scale()

    x: windowCoordinate.x / displayScale
    y: windowCoordinate.y / displayScale

  transformWindowToCanvas: (windowCoordinate) ->
    effectiveScale = @effectiveScale()
    origin = @origin()

    x = windowCoordinate.x
    y = windowCoordinate.y
    width = @canvas.bounds.width()
    height = @canvas.bounds.height()

    x: (x - width / 2) / effectiveScale + origin.x
    y: (y - height / 2) / effectiveScale + origin.y

  transformDisplayToCanvas: (displayCoordinate) ->
    displayScale = @canvas.display.scale()

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
