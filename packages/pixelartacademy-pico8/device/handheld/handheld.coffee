AB = Artificial.Base
AM = Artificial.Mirage
AC = Artificial.Control
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Device.Handheld extends PAA.Pico8.Device
  @id: -> 'PixelArtAcademy.Pico8.Device.Handheld'
  @register @id()

  @version: -> '0.2.0'
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      buttonOn: AEc.ValueTypes.Trigger
      buttonOff: AEc.ValueTypes.Trigger
      buttonPan: AEc.ValueTypes.Number
      smallButtonOn: AEc.ValueTypes.Trigger
      smallButtonOff: AEc.ValueTypes.Trigger
      smallButtonPan: AEc.ValueTypes.Number
      powerSwitchOn: AEc.ValueTypes.Trigger
      powerSwitchOff: AEc.ValueTypes.Trigger
      powerSwitchPan: AEc.ValueTypes.Number
      dPadOn: AEc.ValueTypes.Trigger
      dPadOff: AEc.ValueTypes.Trigger
      dPadPan: AEc.ValueTypes.Number
      
  @dPadStereoWidth = 0.1
  
  constructor: ->
    super arguments...

    @reversedControls = new ReactiveField false

    @buttons = (new ReactiveField false for button in [0..5])
    @powerOn = new ReactiveField false
    @mouseDownDPad = new ReactiveField false
    
    @touches = new ReactiveField null

  onRendered: ->
    super arguments...

    $(document).on 'keydown.pixelartacademy-pico8-device-handheld', (event) =>
      return unless @enabled()
      
      keyCode = event.which
      buttonIndex = @keyCodeToButtonIndex keyCode
      return unless buttonIndex?
      
      if @_isExtraKey keyCode
        @_transferButton buttonIndex, true
        
      else
        @_updateButton buttonIndex, true

    $(document).on 'keyup.pixelartacademy-pico8-device-handheld', (event) =>
      return unless @enabled()
      
      keyCode = event.which
      buttonIndex = @keyCodeToButtonIndex keyCode
      return unless buttonIndex?

      if @_isExtraKey keyCode
        @_transferButton  buttonIndex, false
    
      else
        @_updateButton buttonIndex, false

    $(document).on 'mouseup.pixelartacademy-pico8-device-handheld', (event) =>
      # Cancel all buttons when mouse is released.
      @_transferButtons {}
      @_transferDirections {}

      @mouseDownDPad false
      
    @powerSwitch = @$('.power-switch')[0]
    @menuButton = @$('.menu-button')[0]
    @zButton = @$('.z-button')[0]
    @xButton = @$('.x-button')[0]
    @dPad = @$('.d-pad')[0]

  onDestroyed: ->
    super arguments...

    $(document).off '.pixelartacademy-pico8-device-handheld'
    
  enabled: -> if @options.enabled then @options.enabled() else true
  
  _isExtraKey: (keyCode) ->
    # WASD keys are ones that the device does not detect automatically.
    keyCode in [AC.Keys.w, AC.Keys.a, AC.Keys.s, AC.Keys.d]
  
  _updateButton: (buttonIndex, newValue) ->
    oldValue = @buttons[buttonIndex]() or false
    newValue or= false
    
    return if newValue is oldValue
    
    updatingActionButton = buttonIndex in @constructor.ActionButtons
    updatingDPadButton = buttonIndex in @constructor.DPadButtons
    
    oldDPadDirectionClass = @dPadDirectionClass() if updatingDPadButton
    
    @buttons[buttonIndex] newValue
    
    newDPadDirectionClass = @dPadDirectionClass() if updatingDPadButton
    
    if updatingActionButton
      @_updateActionButtonPan if buttonIndex is @constructor.Buttons.Z then @zButton else @xButton
      
      if newValue then @audio.buttonOn() else @audio.buttonOff()
      
    else
      if newDPadDirectionClass
        if newDPadDirectionClass isnt oldDPadDirectionClass
          @_updateDPadPan buttonIndex
          @audio.dPadOn()
      
      else
        @_updateDPadPan()
        @audio.dPadOff()
  
  _updateActionButtonPan: (button) ->
    @audio.buttonPan AEc.getPanForElement button
    
  _updateDPadPan: (directionIndex) ->
    dPadPan = AEc.getPanForElement @dPad

    switch directionIndex
      when @constructor.Buttons.Left
        dPadPan -= @constructor.dPadStereoWidth / 2
  
      when @constructor.Buttons.Right
        dPadPan += @constructor.dPadStereoWidth / 2
        
    @audio.dPadPan dPadPan
  
  powerStart: ->
    @powerOn true
    
    @_updatePowerSwitchPan()
    @audio.powerSwitchOn()
    
    # Actually start with the delay after the switch has animated.
    Meteor.setTimeout =>
      @start()
    ,
      200

  powerStop: ->
    @powerOn false

    @_updatePowerSwitchPan()
    @audio.powerSwitchOff()

    # Actually stop with the delay after the switch has animated.
    Meteor.setTimeout =>
      @stop()
    ,
      200
  
  _updatePowerSwitchPan: ->
    @audio.powerSwitchPan AEc.getPanForElement @powerSwitch
    
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
    super(arguments...).concat
      'click .power-toggle-button': @onClickPowerToggleButton
      'click .menu-button': @onClickMenuButton
      'mousedown .menu-button': @onMouseDownMenuButton
      'mouseup .menu-button': @onMouseUpMenuButton
      'mousedown .buttons': @onMouseDownButtons
      'touchstart .buttons, touchmove .buttons, touchcancel .buttons, touchend .buttons': @onTouchButtons
      'mousedown .d-pad': @onMouseDownDPad
      'mousemove .d-pad': @onMouseMoveDPad
      'touchstart .d-pad, touchmove .d-pad, touchcancel .d-pad, touchend .d-pad': @onTouchDPad

  onClickPowerToggleButton: (event) ->
    return unless @enabled()
    
    # Toggle power in advance so the switch animates.
    powerOn = not @powerOn()
    @powerOn powerOn

    if powerOn
      @powerStart()

    else
      @powerStop()

  onClickMenuButton: (event) ->
    return unless @enabled()
    
    @reversedControls not @reversedControls()
  
  onMouseDownMenuButton: (event) ->
    @_updateMenuButtonPan()
    @audio.smallButtonOn()
    
  onMouseUpMenuButton: (event) ->
    @_updateMenuButtonPan()
    @audio.smallButtonOff()
    
  _updateMenuButtonPan: ->
    @audio.smallButtonPan AEc.getPanForElement @menuButton

  onMouseDownButtons: (event) ->
    return unless @enabled()
    
    position = @_getNormalizedPosition event, event
    buttonIndex = @_getButtonIndex position

    buttons = "#{buttonIndex}": true
    @_transferButtons buttons

  onTouchButtons: (event) ->
    return unless @enabled()
    
    event.preventDefault()

    buttons = {}

    for touch in event.originalEvent.targetTouches
      position = @_getNormalizedPosition event, touch
      buttonIndex = @_getButtonIndex position
      @_updateButton buttonIndex, true

    @_transferButtons buttons

  _transferButtons: (buttons) ->
    @_transferButton buttonIndex, buttons[buttonIndex] for buttonIndex in [@constructor.Buttons.Z, @constructor.Buttons.X]

  _transferButton: (buttonIndex, newValue) ->
    oldValue = @buttons[buttonIndex]()

    if newValue and not oldValue
      @pressButton buttonIndex
    
    if oldValue and not newValue
      @releaseButton buttonIndex
    
    @_updateButton buttonIndex, newValue

  _getButtonIndex: (position) ->
    if @reversedControls()
      value = position.x - position.y / 4

    else
      value = position.x + position.y / 4

    if value < 0 then @constructor.Buttons.Z else @constructor.Buttons.X

  onMouseDownDPad: (event) ->
    return unless @enabled()
    
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
    return unless @enabled()
    
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
    @_transferButton directionIndex, directions[directionIndex] for directionIndex in [@constructor.Buttons.Left..@constructor.Buttons.Down]

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
