LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.AudioCanvas.Mouse
  constructor: (@audioCanvas) ->
    # The mouse coordinate relative to sprite canvas in native window (browser) pixels.
    @windowCoordinate = new ReactiveField null, EJSON.equals

    # The mouse coordinate relative to sprite canvas as measured in display pixels (as scaled by AM.Display).
    @displayCoordinate = new ReactiveField null, EJSON.equals

    # The floating point value where the mouse is in canvas' coordinate system.
    @canvasCoordinate = new ReactiveField null, EJSON.equals

    # Wire up mouse move and wheel events once the sprite editor is rendered.
    @audioCanvas.autorun (computation) =>
      $audioCanvas = @audioCanvas.$audioCanvas()

      return unless $audioCanvas
      computation.stop()

      @$audioCanvas = $audioCanvas

      $audioCanvas.mousemove (event) =>
        @updateCoordinates event

      # Also react to viewport origin changes.
      Tracker.nonreactive =>
        @audioCanvas.autorun (computation) =>
          @audioCanvas.camera().origin()
          @updateCoordinates()

  updateCoordinates: (event) ->
    if event
      @_lastPageX = event.pageX
      @_lastPageY = event.pageY

    return unless @_lastPageX and @_lastPageY

    origin = @$audioCanvas.offset()
    displayScale = @audioCanvas.display.scale()
    camera = @audioCanvas.camera()

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
