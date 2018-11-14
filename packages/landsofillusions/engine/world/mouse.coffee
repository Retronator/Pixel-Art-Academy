LOI = LandsOfIllusions

class LOI.Engine.World.Mouse
  constructor: (@world) ->
    # The mouse coordinate relative to world canvas in native window (browser) pixels.
    @windowCoordinate = new ReactiveField null, EJSON.equals

    # The mouse coordinate relative to world canvas as measured in display pixels (as scaled by AM.Display).
    @displayCoordinate = new ReactiveField null, EJSON.equals

    # The floating point value where the mouse is in viewport [-1, 1] coordinates.
    @viewportCoordinate = new ReactiveField null, EJSON.equals

    # Wire up mouse move event once the world is rendered.
    @world.autorun (computation) =>
      return unless $world = @world.$world()
      computation.stop()

      @$canvas = $world.find('.canvas')

      $world.mousemove (event) =>
        @_lastPageX = event.pageX
        @_lastPageY = event.pageY
        @updateCoordinates()

      # Remove coordinates when mouse leaves the canvas.
      $world.mouseleave (event) =>
        @windowCoordinate null
        @displayCoordinate null
        @viewportCoordinate null

  updateCoordinates: ->
    origin = @$canvas.offset()
    displayScale = @world.display.scale()

    windowCoordinate =
      x: @_lastPageX - origin.left
      y: @_lastPageY - origin.top

    @windowCoordinate windowCoordinate

    displayCoordinate =
      x: windowCoordinate.x / displayScale
      y: windowCoordinate.y / displayScale

    @displayCoordinate displayCoordinate

    illustrationSize = @world.options.adventure.interface.illustrationSize

    viewportCoordinate =
      x: displayCoordinate.x / illustrationSize.width() * 2 - 1
      y: 1 - displayCoordinate.y / illustrationSize.height() * 2

    @viewportCoordinate viewportCoordinate
