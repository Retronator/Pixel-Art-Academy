AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Interface.Text extends LOI.Adventure.Interface
  @register 'LandsOfIllusions.Adventure.Interface.Text'

  onCreated: ->
    super

    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 240
      maxDisplayWidth: 480
      maxDisplayHeight: 640
      minScale: 2
      minAspectRatio: 1/2
      maxAspectRatio: 2
      debug: false

    @_pausedDialogLine = new ReactiveField null

    @narrative = new LOI.Adventure.Interface.Components.Narrative @

    @commandInput = new LOI.Adventure.Interface.Components.CommandInput
      onEnter: =>
        # Skip this even if we're waiting on dialog.
        return if @_pausedDialogLine()

        command = @commandInput.command().trim()
        return unless command.length

        @narrative.addText "> #{command.toUpperCase()}"
        @adventure.parser.parse command
        @commandInput.clear()

      onKeyDown: =>
        # Scroll to bottom on key press.
        @narrative.scroll()

        # Resume dialog on any key press.
        pausedDialogLine = @_pausedDialogLine()
        return unless pausedDialogLine
        @_pausedDialogLine null

        pausedDialogLine.end()
        @commandInput.clear()
        
  onRendered: ->
    @_previousLineCount = @narrative.linesCount()

    # Enable magnification detection.
    @resizing = new LOI.Adventure.Interface.Text.Resizing @

  onDestroyed: ->
    super

    @commandInput.destroy()

  _handleDialogLine: (dialogLine) ->
    @narrative.addText "#{dialogLine.actor.name} says: \"#{dialogLine.line}\""

    if dialogLine.next
      # Let the user know there is more dialog and wait for their command to continue it.
      @_pausedDialogLine dialogLine

    else
      # We're done with this text so finish it.
      dialogLine.end()

  showCommandLine: ->
    # Show command line unless we're waiting to display dialog.
    not @_pausedDialogLine()

  showInventory: ->
    true

  events: ->
    super.concat
      'mousewheel .scrollable': @onMouseWheelScrollable

  onMouseWheelScrollable: (event) ->
    event.preventDefault()

    $scrollable = $(event.currentTarget)
    $scrollableContent = $scrollable.find('.scrollable-content')

    delta = event.originalEvent.wheelDeltaY
    top = $scrollableContent.position().top
    newTop = top + delta
    
    # Limit scrolling to the amount of content.
    ammountHidden = Math.max 0, $scrollableContent.height() - $scrollable.height()
    newTop = _.clamp newTop, -ammountHidden, 0

    $scrollableContent.css top: newTop
