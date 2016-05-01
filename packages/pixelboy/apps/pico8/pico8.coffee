AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Pico8 extends PAA.PixelBoy.OS.App
  @register 'PixelArtAcademy.PixelBoy.Apps.Pico8'

  displayName: ->
    "Pico-8"

  keyName: ->
    'pico8'

  constructor: ->
    super

    @minWidth 124
    @minHeight 160

    @maxWidth @minWidth()
    @maxHeight @minHeight()

    @resizable false

    @showHomeScreenButton false

    @picoKeyIsPressed = new ReactiveField false
    @isPowerOn = new ReactiveField false

  onActivate: (finishedActivatingCallback) ->
    # Override to perform any logic when item is activated. Report that you've done the necessary
    # steps by calling the provided callback. By default we just call the callback straight away.
    setTimeout( =>
      # power on the pico-8 console!
      # but wait for the resize to finish first
      $('.power-toggle-controller').attr('checked', false)
      @isPowerOn true

      cartridgeUrl = Meteor.absoluteUrl("pico8.png?cartridge=assets/pixelboy/apps/pico8/snake.p8.png&characterId=#{LOI.characterId()}")
      Pico.load $('.pico-container')[0], cartridgeUrl

    , 1000)
    finishedActivatingCallback()

  onRendered: ->
    super

    $(document).keydown (event) =>
      keycode = event.keyCode
      if keycode is 88 or keycode is 86
        keypress = 4
      if keycode is 90 or keycode is 67
        keypress = 5
      if keycode is 38
        keypress = 2
      if keycode is 39
        keypress = 1
      if keycode is 40
        keypress = 3
      if keycode is 37
        keypress = 0

      if keypress isnt null
        $('.pico-button[value="' + keypress + '"]').addClass 'pressed'
        Pico.press keypress, 0
        @picoKeyIsPressed true

    $(document).keyup (event) =>
      keycode = event.keyCode
      if keycode is 88 or keycode is 86
        keypress = 4
      if keycode is 90 or keycode is 67
        keypress = 5
      if keycode is 38
        keypress = 2
      if keycode is 39
        keypress = 1
      if keycode is 40
        keypress = 3
      if keycode is 37
        keypress = 0

      if keypress isnt null
        $('.pico-button[value="' + keypress + '"]').removeClass 'pressed'
        Pico.release keypress, 0
        @picoKeyIsPressed false

  powerOnClass: ->
    'power-on' if @isPowerOn()

  events: ->
    super.concat
      'mousedown .pico-button': @onPressPicoButton
      'mouseup .pico-button, mouseout .pico-button': @onReleasePicoButton
      'change .power-toggle-controller': @onChangePowerToggleController

  onPressPicoButton: (event) ->
    # Get input value.
    keypress = $(event.currentTarget).attr 'value'
    # Send value to pico-8.
    Pico.press keypress, 0
    @picoKeyIsPressed true

  onReleasePicoButton: (event) ->
    if @picoKeyIsPressed()
      keypress = event.currentTarget.value
      # Send value to pico-8.
      Pico.release keypress, 0
      @picoKeyIsPressed false

  onChangePowerToggleController: (event) ->
    powerOn = not @$('.power-toggle-controller')[0].checked
    @isPowerOn powerOn

    if not powerOn
      Meteor.setTimeout =>
        @os.go()
      , 1000
