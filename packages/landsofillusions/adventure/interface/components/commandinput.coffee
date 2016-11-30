AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Interface.Components.CommandInput
  constructor: (@options) ->
    @command = new ReactiveField ""

    # Capture key events.
    $(document).on 'keypress.commandInput', (event) =>
      @onKeyPress event

    $(document).on 'keydown.commandInput', (event) =>
      @onKeyDown event

    console.log "Command input constructed." if LOI.debug

    @idle = new ReactiveField true

    @_resumeIdle = _.debounce =>
      @idle true
    ,
      1000

  destroy: ->
    console.log "Command input destroyed." if LOI.debug

    # Remove key events.
    $(document).off('.commandInput')

  clear: ->
    @command ""

  _notIdle: ->
    @idle false
    @_resumeIdle()

  onKeyPress: (event) ->
    # Don't capture events when interface is not active.
    return unless @options.interface.active()

    # Ignore control characters.
    return if event.which < 32

    character = String.fromCharCode event.which

    command = @command()
    newCommand = "#{command}#{character}"

    @command newCommand

    @_notIdle()

  onKeyDown: (event) ->
    interfaceActive = @options.interface.active()

    console.log "Command input detected a key down and is checking if interface is active:", interfaceActive if LOI.debug

    # Don't capture events when interface is not active.
    return unless interfaceActive

    switch event.which
      # Backspace
      when 8
        event.preventDefault()

        command = @command()
        return unless command.length

        newCommand = command.substring 0, command.length-1
        @command newCommand

        @_notIdle()

      # Enter
      when 13
        @options?.onEnter?()

    # Trigger event for any key down.
    @options?.onKeyDown?()
