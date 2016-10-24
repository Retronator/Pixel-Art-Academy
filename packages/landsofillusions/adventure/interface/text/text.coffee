AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

Nodes = LOI.Adventure.Script.Nodes

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

    @_pausedDialogLines = new ReactiveField null

    @narrative = new LOI.Adventure.Interface.Components.Narrative
      textInterface: @

    @commandInput = new LOI.Adventure.Interface.Components.CommandInput
      onEnter: => @onCommandInputEnter()
      onKeyDown: => @onCommandInputKeyDown()

    @dialogSelection = new LOI.Adventure.Interface.Components.DialogSelection
      interface: @
      onEnter: => @onDialogSelectionEnter()

  onRendered: ->
    super

    @_previousLineCount = @narrative.linesCount()

    # Enable magnification detection.
    @resizing = new LOI.Adventure.Interface.Text.Resizing @

  onDestroyed: ->
    super

    @commandInput.destroy()
    
  onLocationChanged: (location) ->
    @narrative?.clear()
      
  introduction: ->
    location = @location()
    return unless location
    
    if location.constructor.visited
      fullName = location.fullName()
      return unless fullName

      # We've already visited this location so simply return the full name.
      "#{_.upperFirst fullName.text}."

    else
      # It's the first time we're visiting this location in this session so show the full description.
      location.description()?.text
      
  exits: ->
    exits = @location()?.exits()
    return [] unless exits
    
    for directionKey, locationId of exits
      directionKey: directionKey
      locationId: locationId

  exitName: ->
    exit = @currentData()
    location = @location()
    
    # Find exit's location name.
    subscriptionHandle = location.exitsTranslationSubscribtions[exit.locationId]
    key = LOI.Adventure.Location.translationKeys.shortName

    AB.translate(subscriptionHandle, key).text

  showCommandLine: ->
    # Show command line unless we're displaying a dialog.
    not @showDialogSelection() and not @_pausedDialogLines()

  showDialogSelection: ->
    # After the new choices are re-rendered, scroll down the narrative.
    Tracker.afterFlush => @narrative.scroll()

    # Show the dialog selection when we have some choices available.
    @dialogSelection.dialogLineOptions()

  activeDialogOptionClass: ->
    option = @currentData()

    'active' if option is @dialogSelection.selectedDialogLine()

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

  onCommandInputEnter: ->
    # Resume dialog on any key press.
    pausedDialogLines = @_pausedDialogLines()
    if pausedDialogLines
      @_pausedDialogLines null

      # Transition from the first dialog line to the next of the last.
      firstDialogLine = _.first pausedDialogLines
      lastDialogLine = _.last pausedDialogLines

      firstDialogLine.director.scriptTransition firstDialogLine, lastDialogLine.next

      # Clear the command input in case it accumulated any text in the mean time.
      @commandInput.clear()
      return

    command = @commandInput.command().trim()
    return unless command.length

    @narrative.addText "> #{command.toUpperCase()}"
    @adventure.parser.parse command
    @commandInput.clear()

  onCommandInputKeyDown: ->
    # Scroll to bottom on key press.
    @narrative.scroll()
    
  onDialogSelectionEnter: ->
    # Continue with the selection.
    @_dialogSelectionConfirm()

  _dialogSelectionConfirm: ->
    @dialogSelection.confirm()

  # Overrides for how the text adventure interface deals with script nodes.

  _handleDialogLine: (dialogLine) ->
    unless dialogLine.actor
      # There is no actor, which means the player is saying this. Simply dump it into the narrative and finish.
      @narrative.addText "> \"#{dialogLine.line.toUpperCase()}\""
      dialogLine.end()
      return

    # We have an actor that is saying this. Collect all the dialog lines in a row by the same actor.
    dialogLines = [dialogLine]
    scriptNode = dialogLine

    while scriptNode = scriptNode.next
      # Search for another dialog line by the same actor.
      if scriptNode instanceof Nodes.DialogLine and scriptNode.actor is dialogLine.actor
        # Found another one, add it and continue.
        dialogLines.push scriptNode

      else
        # Nothing more to be found, so stop looking.
        break

    # Add a new paragraph to the narrative for each line.
    for dialogLine in dialogLines
      text = dialogLine.line

      # Add the intro line at the start.
      if dialogLine is _.first dialogLines
        text = "#{dialogLine.actor.avatar.shortName()} says: \"#{text}"

      # Add the closing quote at the end.
      if dialogLine is _.last dialogLines
        text = "#{text}\""

      # Present the text to the player.
      @narrative.addText text

    # Wait for player's command to continue.
    @_pausedDialogLines dialogLines
