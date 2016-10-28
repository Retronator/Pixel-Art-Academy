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

  destroy: ->
    # Remove key events.
    $(document).off('.commandInput')

  clear: ->
    @command ""

  onKeyPress: (event) ->
    # Don't capture events when interface is not active.

    # Ignore control characters.
    return if event.which < 32

    character = String.fromCharCode event.which

    command = @command()
    newCommand = "#{command}#{character}"

    @command newCommand

  onKeyDown: (event) ->
    # Don't capture events when interface is not active.
    return unless @options.interface.active()

    switch event.which
      # Backspace
      when 8
        event.preventDefault()

        command = @command()
        return unless command.length

        newCommand = command.substring 0, command.length-1
        @command newCommand

      # Enter
      when 13
        @options?.onEnter?()

    # Trigger event for any key down.
    @options?.onKeyDown?()
