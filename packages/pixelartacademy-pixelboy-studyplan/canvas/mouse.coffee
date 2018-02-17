LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.StudyPlan.Canvas.Mouse
  constructor: (@canvas) ->
    # The mouse coordinate relative to sprite canvas in native window (browser) pixels.
    @windowCoordinate = new ReactiveField null, EJSON.equals

    # The mouse coordinate relative to sprite canvas as measured in display pixels (as scaled by AM.Display).
    @displayCoordinate = new ReactiveField null, EJSON.equals

    # The floating point value where the mouse is in canvas' coordinate system.
    @canvasCoordinate = new ReactiveField null, EJSON.equals

    # Wire up mouse move and wheel events once the sprite editor is rendered.
    @canvas.autorun (computation) =>
      $canvas = @canvas.$canvas()

      return unless $canvas
      computation.stop()

      @$canvas = $canvas

      $canvas.mousemove (event) =>
        @_lastPageX = event.pageX
        @_lastPageY = event.pageY
        @updateCoordinates()

      # Also react to viewport origin changes.
      Tracker.nonreactive =>
        @canvas.autorun (computation) =>
          @canvas.camera().origin()
          @updateCoordinates()

  updateCoordinates: ->
    origin = @$canvas.offset()
    displayScale = @canvas.display.scale()
    camera = @canvas.camera()

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
