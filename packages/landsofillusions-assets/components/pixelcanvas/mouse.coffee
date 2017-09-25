LOI = LandsOfIllusions

class LOI.Assets.Components.PixelCanvas.Mouse
  constructor: (@pixelCanvas) ->
    # The mouse coordinate relative to sprite canvas in native window (browser) pixels.
    @windowCoordinate = new ReactiveField null, EJSON.equals

    # The mouse coordinate relative to sprite canvas as measured in display pixels (as scaled by AM.Display).
    @displayCoordinate = new ReactiveField null, EJSON.equals

    # The floating point value where the mouse is in canvas' coordinate system.
    @canvasCoordinate = new ReactiveField null, EJSON.equals

    # The integer value of sprite's pixel the mouse is hovering over.
    @pixelCoordinate = new ReactiveField null, EJSON.equals

    # Wire up mouse move and wheel events once the sprite editor is rendered.
    @pixelCanvas.autorun (computation) =>
      $pixelCanvas = @pixelCanvas.$pixelCanvas()

      return unless $pixelCanvas
      computation.stop()

      @$canvas = $pixelCanvas.find('.canvas')

      $pixelCanvas.mousemove (event) =>
        @_lastPageX = event.pageX
        @_lastPageY = event.pageY
        @updateCoordinates()

      # Also react to viewport origin changes.
      Tracker.nonreactive =>
        @pixelCanvas.autorun (computation) =>
          @pixelCanvas.camera().origin()
          @updateCoordinates()

  updateCoordinates: ->
    origin = @$canvas.offset()
    displayScale = @pixelCanvas.display.scale()
    camera = @pixelCanvas.camera()

    windowCoordinate =
      x: @_lastPageX - origin.left
      y: @_lastPageY - origin.top

    @windowCoordinate windowCoordinate

    displayCoordinate =
      x: windowCoordinate.x / displayScale
      y: windowCoordinate.y / displayScale

    @displayCoordinate displayCoordinate

    canvasCoordinate = camera.transformDisplayToCanvas displayCoordinate
    @canvasCoordinate canvasCoordinate

    pixelCoordinate =
      x: Math.floor canvasCoordinate.x
      y: Math.floor canvasCoordinate.y

    @pixelCoordinate pixelCoordinate
