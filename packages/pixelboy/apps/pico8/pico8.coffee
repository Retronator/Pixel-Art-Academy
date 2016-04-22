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
    super
    @picoKeyIsPressed = new ReactiveField false

  events: ->
    super.concat
      'mousedown .pico-button': @onClickPicoButton
      'mouseup .pico-button, mouseout .pico-button': @onReleasePicoButton

  onClickPicoButton: (event) ->
    # get input value
    keypress = event.currentTarget.value
    # send value to pico-8
    # PicoPress(keypress, 0)
    @picoKeyIsPressed true

  onReleasePicoButton: (event) ->
    if @picoKeyIsPressed()
      keypress = event.currentTarget.value
      #send value to pico-8
      # PicoRelease(keypress, 0)
      console.log 'release ', keypress
      @picoKeyIsPressed false
