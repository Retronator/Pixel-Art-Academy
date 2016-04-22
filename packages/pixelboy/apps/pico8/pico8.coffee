AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Pico8 extends PAA.PixelBoy.OS.App
  @register 'PixelArtAcademy.PixelBoy.Apps.Pico8'

  displayName: ->
    "Pico-8"

  urlName: ->
    'pico8'

  constructor: ->
    @picoKeyIsPressed = new ReactiveField false

  onRendered: ->
    super

    Pico.load $('.pico-container')[0], 'http://localhost.pixelart.academy:3005/pico8.png?cartridge=http%3A%2F%2Flocalhost.pixelart.academy%3A3005%2Fassets%2Fpixelboy%2Fapps%2Fpico8%2Ftest.p8.png'

  events: ->
    super.concat
      'mousedown .pico-button': @onPressPicoButton
      'mouseup .pico-button, mouseout .pico-button': @onReleasePicoButton

  onPressPicoButton: (event) ->
    # Get input value.
    keypress = event.currentTarget.value
    
    # Send value to pico-8.
    Pico.press keypress, 0
    @picoKeyIsPressed true

  onReleasePicoButton: (event) ->
    if @picoKeyIsPressed()
      keypress = event.currentTarget.value
      
      # Send value to pico-8.
      Pico.release keypress, 0
      @picoKeyIsPressed false
