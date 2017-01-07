AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Interface.Text extends LOI.Interface.Text
  initializeHandlers: ->
    # Listen for command input changes.
    @autorun (computation) =>
      @commandInput.command()
      @onCommandInputChanged()

    # Pause dialog selection when we're waiting for a key press ourselves.
    @autorun (computation) =>
      @dialogSelection.paused @waitingKeypress()

  onLocationChanged: (location) ->
    @narrative?.clear()

    # Wait for location to load.
    Tracker.autorun (computation) =>
      return unless location.ready()
      computation.stop()

      # All the texts have been loaded from the DB at this point. Wait for everything to be rendered.
      Tracker.afterFlush =>
        @resize()

        # Set scroll position to reveal the top or the bottom of the UI.
        scrollPosition = if location.constructor.visited() then @maxScrollTop() else 0
        @scroll position: scrollPosition

  onCommandInputEnter: ->
    # Resume dialog on any key press.
    if pausedLineNode = @_pausedNode()
      # Clear the paused node and handle it.
      @_pausedNode null
      @_handleNode pausedLineNode

      # Clear the command input in case it accumulated any text in the mean time.
      @commandInput.clear()
      return

    @_executeCommand @hoveredCommand() or @commandInput.command().trim()

    # Scroll to bottom on enter.
    @narrative.scroll()

  _executeCommand: (command) ->
    return unless command.length

    @narrative.addText "> #{command.toUpperCase()}"
    @options.adventure.parser.parse command
    @commandInput.clear()

  onCommandInputChanged: ->
    # Scroll to bottom to reveal new command.
    @narrative.scroll()
    
  onDialogSelectionEnter: ->
    # Continue with the selection.
    @_dialogSelectionConfirm()

  _dialogSelectionConfirm: ->
    @dialogSelection.confirm()    
