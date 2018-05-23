AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Components.PixelCanvas.Camera
  constructor: (@pixelCanvas, @options = {}) ->
    _.defaults @options,
      enableInput: true

    # At camera scale 1, a canvas pixel matches a display pixel (and not window pixel).
    # Scale is used to go from canvas pixels to display pixels.
    @scale = new ReactiveField (@options.initialScale or 1), EJSON.equals

    # We support adding delay to change in scale. In that case target scale
    # changes immediately and scale only after the delay has passed.
    @targetScale = new ReactiveField @scale()

    # Effective scale includes the amount we're scaling our display pixels.
    # It is used to go from canvas pixels to window pixels.
    @effectiveScale = new ComputedField =>
      displayScale = @pixelCanvas.display.scale()
      @scale() * displayScale

    @origin = new ReactiveField
      x: @options.initialOrigin?.x or 0
      y: @options.initialOrigin?.y or 0
    , EJSON.equals

    # Calculate viewport in canvas coordinates.
    @viewportBounds = new AE.Rectangle()

    @pixelCanvas.autorun =>
      canvasBounds = @pixelCanvas.canvasBounds
      effectiveScale = @effectiveScale()
      origin = @origin()

      # Calculate which part of the canvas is visible. Canvas bounds is in window pixels.
      width = canvasBounds.width() / effectiveScale
      height = canvasBounds.height() / effectiveScale

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

          @origin
            x: oldOrigin.x + canvasDelta.x
            y: oldOrigin.y + canvasDelta.y

  setScale: (scale) ->
    # Notify to which scale we're going.
    @targetScale scale

    # Cancel any previous scale update, so the new scale will go into effect.
    Meteor.clearTimeout @_scaleUpdateTimeout if @_scaleUpdateTimeout

    if @options.scaleDelay
      @_scaleUpdateTimeout = Meteor.setTimeout =>
        # Trigger main scale update.
        @scale scale

        # Mark the timeout as handled.
        @_scaleUpdateTimeout = null
      ,
        @options.scaleDelay

    else
      @scale scale

  applyTransformToCanvas: ->
    context = @pixelCanvas.context()
    canvasBounds = @pixelCanvas.canvasBounds
    effectiveScale = @effectiveScale()
    origin = @origin()

    # Start from the identity.
    context.setTransform 1, 0, 0, 1, 0, 0

    # Move to center of screen.
    width = canvasBounds.width()
    height = canvasBounds.height()
    context.translate width / 2, height / 2

    # Scale the canvas around the origin.
    context.scale effectiveScale, effectiveScale

    # Move to origin.
    context.translate -origin.x, -origin.y

  transformCanvasToWindow: (canvasCoordinate) ->
    canvasBounds = @pixelCanvas.canvasBounds
    effectiveScale = @effectiveScale()
    origin = @origin()

    x = canvasCoordinate.x
    y = canvasCoordinate.y
    width = canvasBounds.width()
    height = canvasBounds.height()

    x: (x - origin.x) * effectiveScale + width / 2
    y: (y - origin.y) * effectiveScale + height / 2

  transformCanvasToDisplay: (canvasCoordinate) ->
    windowCoordinate = @transformCanvasToWindow canvasCoordinate
    displayScale = @pixelCanvas.display.scale()

    x: windowCoordinate.x / displayScale
    y: windowCoordinate.y / displayScale

  transformWindowToCanvas: (windowCoordinate) ->
    canvasBounds = @pixelCanvas.canvasBounds
    effectiveScale = @effectiveScale()
    origin = @origin()

    x = windowCoordinate.x
    y = windowCoordinate.y
    width = canvasBounds.width()
    height = canvasBounds.height()

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
