AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Pico8 extends PAA.PixelBoy.App
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Pico8'
  @url: -> 'pico8'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Pico-8"
  @description: ->
    "
      It's Lexaloffle's fantasy console!
    "

  @initialize()

  constructor: ->
    super

    @minWidth 118
    @minHeight 152

    @maxWidth @minWidth()
    @maxHeight @minHeight()

    @resizable false

    @picoKeyIsPressed = new ReactiveField false
    @isPowerOn = new ReactiveField false

  onActivate: (finishedActivatingCallback) ->
    # Override to perform any logic when item is activated. Report that you've done the necessary
    # steps by calling the provided callback. By default we just call the callback straight away.
    setTimeout =>
      # Power on the pico-8 console, but wait for the resize to finish first.
      $('.power-toggle-controller').attr('checked', false)
      @isPowerOn true

      cartridgeUrl = Meteor.absoluteUrl("pico8.png?cartridge=pixelartacademy/pixelboy/apps/pico8/snake.p8.png&characterId=#{LOI.characterId()}")
      Pico.load $('.pico-container')[0], cartridgeUrl
    ,
      1000
    
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
