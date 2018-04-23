LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.StudyPlan.Blueprint.Mouse
  constructor: (@blueprint) ->
    # The mouse coordinate relative to sprite canvas in native window (browser) pixels.
    @windowCoordinate = new ReactiveField null, EJSON.equals

    # The mouse coordinate relative to sprite canvas as measured in display pixels (as scaled by AM.Display).
    @displayCoordinate = new ReactiveField null, EJSON.equals

    # The floating point value where the mouse is in canvas' coordinate system.
    @canvasCoordinate = new ReactiveField null, EJSON.equals

    # Wire up mouse move and wheel events once the sprite editor is rendered.
    @blueprint.autorun (computation) =>
      $blueprint = @blueprint.$blueprint()

      return unless $blueprint
      computation.stop()

      @$blueprint = $blueprint

      $blueprint.mousemove (event) =>
        @updateCoordinates event

      # Also react to viewport origin changes.
      Tracker.nonreactive =>
        @blueprint.autorun (computation) =>
          @blueprint.camera().origin()
          @updateCoordinates()

  updateCoordinates: (event) ->
    if event
      @_lastPageX = event.pageX
      @_lastPageY = event.pageY

    return unless @_lastPageX and @_lastPageY

    origin = @$blueprint.offset()
    displayScale = @blueprint.display.scale()
    camera = @blueprint.camera()

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
