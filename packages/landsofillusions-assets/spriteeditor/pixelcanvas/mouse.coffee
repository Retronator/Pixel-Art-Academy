LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.PixelCanvas.Mouse
  constructor: (@pixelCanvas) ->
    # The mouse coordinate relative to sprite canvas in native window (browser) pixels.
    @windowCoordinate = new ReactiveField null, EJSON.equals

    # The mouse coordinate relative to sprite canvas as measured in display pixels (as scaled by AM.Display).
    @displayCoordinate = new ReactiveField null, EJSON.equals

    # The floating point value where the mouse is in canvas' coordinate system.
    @canvasCoordinate = new ReactiveField null, EJSON.equals

    # The integer value of asset's pixel the mouse is hovering over.
    @pixelCoordinate = new ReactiveField null, EJSON.equals

    # Wire up mouse move event once the sprite editor is rendered.
    @pixelCanvas.autorun (computation) =>
      $pixelCanvas = @pixelCanvas.$pixelCanvas()

      return unless $pixelCanvas
      computation.stop()

      $pixelCanvas.mousemove (event) =>
        @_lastPageX = event.pageX
        @_lastPageY = event.pageY
        @updateCoordinates()
  
      $pixelCanvas.on 'pointermove', (event) =>
        @_lastPageX = event.pageX
        @_lastPageY = event.pageY
        @updateCoordinates()

      # Also react to viewport origin changes, when we have existing coordinates set.
      Tracker.nonreactive =>
        @pixelCanvas.autorun (computation) =>
          @pixelCanvas.camera().origin()
          @updateCoordinates() if @pixelCoordinate()

      # Remove coordinates when mouse leaves the canvas.
      $pixelCanvas.mouseleave (event) =>
        @windowCoordinate null
        @displayCoordinate null
        @canvasCoordinate null
        @pixelCoordinate null

  updateCoordinates: ->
    $pixelCanvas = @pixelCanvas.$pixelCanvas()
    pixelCanvasPosition = $pixelCanvas.offset()
    displayScale = @pixelCanvas.display.scale()
    camera = @pixelCanvas.camera()

    windowCoordinate =
      x: @_lastPageX - pixelCanvasPosition.left
      y: @_lastPageY - pixelCanvasPosition.top

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
