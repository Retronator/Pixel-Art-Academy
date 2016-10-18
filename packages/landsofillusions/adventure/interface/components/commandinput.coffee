AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Interface.Components.CommandInput
  constructor: (@options) ->
    @command = new ReactiveField ""

    # Capture key events.
    $(document).keypress (event) =>
      @onKeyPress event

    $(document).keydown (event) =>
      @onKeyDown event

  destroy: ->
    # Remove key events.
    $(document).off('keypress')
    $(document).off('keydown')

  clear: ->
    @command ""

  onKeyPress: (event) ->
    # Ignore control characters.
    return if event.which < 32

    character = String.fromCharCode event.which

    command = @command()
    newCommand = "#{command}#{character}"

    @command newCommand

  onKeyDown: (event) ->
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
