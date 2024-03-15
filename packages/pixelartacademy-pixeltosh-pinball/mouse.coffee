LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Mouse
  constructor: (@pinball) ->
    # The mouse coordinate relative to the playfield view in native window (browser) pixels.
    @windowCoordinates = new ReactiveField null, EJSON.equals

    # The floating point value where the mouse is in viewport [-1, 1] coordinates.
    @viewportCoordinates = new ReactiveField null, EJSON.equals

  onMouseMove: (event) ->
    $playfield = @pinball.os.$('.pixelartacademy-pixeltosh-programs-pinball-interface-playfield')

    origin = $playfield.offset()

    windowCoordinates =
      x: event.pageX - origin.left
      y: event.pageY - origin.top

    @windowCoordinates windowCoordinates

    viewportCoordinates =
      x: windowCoordinates.x / $playfield.width() * 2 - 1
      y: 1 - windowCoordinates.y / $playfield.height() * 2

    @viewportCoordinates viewportCoordinates

  onMouseLeave: ->
    @windowCoordinates null
    @viewportCoordinates null
