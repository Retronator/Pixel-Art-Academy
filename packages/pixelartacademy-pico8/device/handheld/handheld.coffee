AB = Artificial.Babel
AM = Artificial.Mirage
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Device.Handheld extends PAA.Pico8.Device
  @id: -> 'PixelArtAcademy.Pico8.Device.Handheld'
  @register @id()

  @version: -> '0.2.0'

  constructor: ->
    super

    @reversedControls = new ReactiveField false

    @buttons = (new ReactiveField false for button in [0..5])
    @powerOn = new ReactiveField false
    @mouseDownDPad = new ReactiveField false
    
    @touches = new ReactiveField null

  onRendered: ->
    super

    $(document).on 'keydown.pixelartacademy-pico8-device-handheld', (event) =>
      keyCode = event.which
      buttonIndex = @keyCodeToButtonIndex keyCode
      @buttons[buttonIndex] true if buttonIndex?

    $(document).on 'keyup.pixelartacademy-pico8-device-handheld', (event) =>
      keyCode = event.which
      buttonIndex = @keyCodeToButtonIndex keyCode
      @buttons[buttonIndex] false if buttonIndex?

    $(document).on 'mouseup.pixelartacademy-pico8-device-handheld', (event) =>
      # Cancel all buttons when mouse is released.
      @_transferButtons {}
      @_transferDirections {}

      @mouseDownDPad false

  onDestroyed: ->
    super

    $(document).off '.pixelartacademy-pico8-device-handheld'

  startGame: (game, project) ->
    super

    @powerOn true

  canvasElement: ->
    @$('.canvas')[0]

  reversedControlsClass: ->
    'reversed-controls' if @reversedControls()

  powerOnClass: ->
    'power-on' if @powerOn()

  zButtonPressedClass: ->
    'pressed' if @buttons[@constructor.Buttons.Z]()

  xButtonPressedClass: ->
    'pressed' if @buttons[@constructor.Buttons.X]()

  dPadDirectionClass: ->
    return 'left' if @buttons[@constructor.Buttons.Left]()
    return 'right' if @buttons[@constructor.Buttons.Right]()
    return 'up' if @buttons[@constructor.Buttons.Up]()
    return 'down' if @buttons[@constructor.Buttons.Down]()
    null

  events: ->
    super.concat
      'click .power-toggle-button': @onClickPowerToggleButton
      'click .menu-button': @onClickMenuButton
      'mousedown .buttons': @onMouseDownButtons
      'touchstart .buttons, touchmove .buttons, touchcancel .buttons, touchend .buttons': @onTouchButtons
      'mousedown .d-pad': @onMouseDownDPad
      'mousemove .d-pad': @onMouseMoveDPad
      'touchstart .d-pad, touchmove .d-pad, touchcancel .d-pad, touchend .d-pad': @onTouchDPad

  onClickPowerToggleButton: (event) ->
    @powerOn not @powerOn()

    if @powerOn()
      Meteor.setTimeout =>
        @startGame
          cartridge:
            url: '/pixelartacademy/pixelboy/apps/pico8/snake.p8.png'
      ,
        200

  onClickMenuButton: (event) ->
    @reversedControls not @reversedControls()

  onMouseDownButtons: (event) ->
    position = @_getNormalizedPosition event, event
    buttonIndex = @_getButtonIndex position

    buttons = "#{buttonIndex}": true
    @_transferButtons buttons

  onTouchButtons: (event) ->
    event.preventDefault()

    buttons = {}

    for touch in event.originalEvent.targetTouches
      position = @_getNormalizedPosition event, touch
      buttonIndex = @_getButtonIndex position
      buttons[buttonIndex] = true

    @_transferButtons buttons

  _transferButtons: (buttons) ->
    @_transferButton buttons, buttonIndex for buttonIndex in [@constructor.Buttons.Z, @constructor.Buttons.X]

  _transferButton: (buttons, buttonIndex) ->
    oldValue = @buttons[buttonIndex]()
    newValue = buttons[buttonIndex]

    @pressButton buttonIndex if newValue and not oldValue
    @releaseButton buttonIndex if oldValue and not newValue

    @buttons[buttonIndex] newValue

  _getButtonIndex: (position) ->
    if @reversedControls()
      value = position.x - position.y / 4

    else
      value = position.x + position.y / 4

    if value < 0 then @constructor.Buttons.Z else @constructor.Buttons.X

  onMouseDownDPad: (event) ->
    @mouseDownDPad true
    @_processMouseOnDPad event

  onMouseMoveDPad: (event) ->
    return unless @mouseDownDPad()

    @_processMouseOnDPad event

  _processMouseOnDPad: (event) ->
    # Mouse uses a small dead zone.
    deadZone = 0.2

    directions = {}

    position = @_getNormalizedPosition event, event
    @_setDPadDirection position, deadZone, directions

    @_transferDirections directions

  onTouchDPad: (event) ->
    event.preventDefault()

    # Touch uses a bigger dead zone.
    deadZone = 0.3

    directions = {}

    @touches (Math.floor(touch.clientX) + "," + Math.floor(touch.clientY) for touch in event.originalEvent.targetTouches)

    for touch in event.originalEvent.targetTouches
      position = @_getNormalizedPosition event, touch
      @_setDPadDirection position, deadZone, directions

    @_transferDirections directions

  _transferDirections: (directions) ->
    @_transferButton directions, directionIndex for directionIndex in [@constructor.Buttons.Left..@constructor.Buttons.Down]

  _setDPadDirection: (position, deadZone, directions) ->
    distance = Math.sqrt(Math.pow(position.x, 2) + Math.pow(position.y, 2))
    return if distance < deadZone

    angle = Math.atan2(-position.y, position.x) * 180 / Math.PI

    directions[@constructor.Buttons.Left] = true if angle < -120 or angle > 120
    directions[@constructor.Buttons.Right] = true if -60 < angle < 60
    directions[@constructor.Buttons.Up] = true if 30 < angle < 150
    directions[@constructor.Buttons.Down] = true if -150 < angle < -30

  _getNormalizedPosition: (event, position) ->
    $surface = $(event.currentTarget)

    width = $surface.width()
    height = $surface.height()
    offset = $surface.offset()

    x: (position.clientX - offset.left) / width * 2 - 1
    y: (position.clientY - offset.top) / height * 2 - 1
