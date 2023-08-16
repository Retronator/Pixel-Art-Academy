AB = Artificial.Babel
AM = Artificial.Mirage
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Device extends LOI.Component
  @Buttons:
    Left: 0
    Right: 1
    Up: 2
    Down: 3
    Z: 4
    X: 5
    
  @DPadButtons: [0, 1, 2, 3]
  @ActionButtons: [4, 5]

  constructor: (@options = {}) ->
    super arguments...

    @game = new ReactiveField null
    @projectId = new ReactiveField null

  onCreated: ->
    super arguments...

    @project = new ComputedField =>
      return unless projectId = @projectId()
      PAA.Practice.Project.forId.subscribe @, projectId
      PAA.Practice.Project.documents.findOne projectId
      
  onDestroyed: ->
    super arguments...
    
    @stop() if @_started

  loadGame: (game, projectId) ->
    @game game
    @projectId projectId

  start: ->
    @stop() if @_started
    @_started = true
    
    # Create the canvas for PICO-8 display.
    @_$canvas = $('<canvas>')
    @$('.screen').append(@_$canvas)

    # Clear the pixel replacement cache since changes up to now will be already included in the cartridge itself.
    @_updatedPixels = []

    game = @game()

    if projectId = @projectId()
      # We need to get a modified cartridge PNG with the project's assets.
      game.getCartridgeImageUrlForProject(projectId).then (url) => @_startWithCartridgeUrl url

    else
      # We can use the cartridge PNG directly.
      @_startWithCartridgeUrl game.cartridge.url

  _startWithCartridgeUrl: (cartridgeUrl) ->
    console.groupCollapsed "PICO-8"
    
    PAA.Pico8.Device.Module =
      audioContext: @options.audioContext
      audioOutputNode: @options.audioOutputNode
      arguments: [cartridgeUrl]
      canvas: @_$canvas[0]
      postRun: [
          =>
            # Enable PICO-8 runtime to exit normally. We need to do this in postRun since it gets set to true on run.
            PAA.Pico8.Device.Module.noExitRuntime = false
        ]
      onExit: => console.groupEnd()
      gpio: (address, value) =>
        @options.onInputOutput? address, value
        @handleSpriteReplacementIO address, value

    # Start PICO-8 runtime.
    # HACK: We simply add the script every time we launch to have the runtime use the new Module.
    runtimeUrl = '/packages/retronator_pixelartacademy-pico8/device/runtime/pico8.min.js'
    $('head').append("<script src='#{runtimeUrl}'>")
    
  stop: ->
    # Remove the display.
    @_$canvas?.remove()

    # Clean up audio context, if it wasn't provided through options.
    PAA.Pico8.Device.Module?.audioContext.close() unless @options.audioContext

    # Exit PICO-8 module, which will throw an exit status, so we catch it.
    try
      PAA.Pico8.Device.Module?.exit(0)

    catch exitStatus
    
    @_started = false

  pressButton: (buttonIndex) ->
    PAA.Pico8.Device.Module?.SDL.events.push
      type: 'keydown'
      keyCode: @buttonIndexToKeyCode buttonIndex

  releaseButton: (buttonIndex) ->
    PAA.Pico8.Device.Module?.SDL.events.push
      type: 'keyup'
      keyCode: @buttonIndexToKeyCode buttonIndex

  keyCodeToButtonIndex: (keyCode) ->
    switch keyCode
      when AC.Keys.left, AC.Keys.a then @constructor.Buttons.Left
      when AC.Keys.right, AC.Keys.d then @constructor.Buttons.Right
      when AC.Keys.up, AC.Keys.w then @constructor.Buttons.Up
      when AC.Keys.down, AC.Keys.s then @constructor.Buttons.Down
      when AC.Keys.z, AC.Keys.c, AC.Keys.n then @constructor.Buttons.Z
      when AC.Keys.x, AC.Keys.v, AC.Keys.m then @constructor.Buttons.X
      else
        null

  buttonIndexToKeyCode: (buttonIndex) ->
    switch buttonIndex
      when @constructor.Buttons.Left then AC.Keys.left
      when @constructor.Buttons.Right then AC.Keys.right
      when @constructor.Buttons.Up then AC.Keys.up
      when @constructor.Buttons.Down then AC.Keys.down
      when @constructor.Buttons.Z then AC.Keys.z
      when @constructor.Buttons.X then AC.Keys.x
