LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Mouse
  constructor: (@stillLifeStand) ->
    # The mouse coordinate relative to still life stand display in native window (browser) pixels.
    @windowCoordinates = new ReactiveField null, EJSON.equals

    # The floating point value where the mouse is in viewport [-1, 1] coordinates.
    @viewportCoordinates = new ReactiveField null, EJSON.equals

  onMouseMove: (event) ->
    @$viewportArea ?= @stillLifeStand.$('.viewport-area')

    origin = @$viewportArea.offset()

    windowCoordinates =
      x: event.pageX - origin.left
      y: event.pageY - origin.top

    @windowCoordinates windowCoordinates

    viewportCoordinates =
      x: windowCoordinates.x / @$viewportArea.width() * 2 - 1
      y: 1 - windowCoordinates.y / @$viewportArea.height() * 2

    @viewportCoordinates viewportCoordinates

  onMouseLeave: ->
    @windowCoordinates null
    @viewportCoordinates null
