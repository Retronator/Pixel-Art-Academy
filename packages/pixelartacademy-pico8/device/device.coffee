AB = Artificial.Babel
AM = Artificial.Mirage
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Device extends AM.Component
  @Buttons:
    Left: 0
    Right: 1
    Up: 2
    Down: 3
    Z: 4
    X: 5

  onCreated: ->
    super

    @game = new ReactiveField null
    @projectId = new ReactiveField null

    @project = new ComputedField =>
      return unless projectId = @projectId()
      PAA.Practice.Project.forId.subscribe @, projectId
      PAA.Practice.Project.documents.findOne projectId

  loadGame: (game, projectId) ->
    @game game
    @projectId projectId

    if projectId
      # We need to create a modified cartridge PNG with the project's assets.
      @cartridgeUrl = Meteor.absoluteUrl "pico8/cartridge.png?gameId=#{game._id}&projectId=#{projectId}"

    else
      # We can use the cartridge PNG directly.
      @cartridgeUrl = game.cartridge.url

  start: ->
    # Create the canvas for PICO-8 display.
    @_$canvas = $('<canvas>')
    @$('.screen').append(@_$canvas)

    # Prepare buffer for IO transfers.
    io = []

    PAA.Pico8.Device.Module =
      arguments: [@cartridgeUrl]
      canvas: @_$canvas[0]
      postRun: [
          =>
            # Enable PICO-8 runtime to exit normally. We need to do this in postRun since it gets set to true on run.
            PAA.Pico8.Device.Module.noExitRuntime = false
        ]
      gpio: (address, value) =>
        @handleSpriteReplacementIO address, value

    # Start PICO-8 runtime.
    runtimeUrl = '/packages/retronator_pixelartacademy-pico8/device/runtime/pico8.min.js'
    $('head').append("<script src='#{runtimeUrl}'>")
    
  stop: ->
    # Remove the display.
    @_$canvas.remove()

    # Clean up audio context.
    PAA.Pico8.Device.Module.audioContext.close()

    try
      PAA.Pico8.Device.Module.exit(0)

    catch error

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
      when AC.Keys.left then @constructor.Buttons.Left
      when AC.Keys.right then @constructor.Buttons.Right
      when AC.Keys.up then @constructor.Buttons.Up
      when AC.Keys.down then @constructor.Buttons.Down
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
