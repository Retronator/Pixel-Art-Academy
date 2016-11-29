AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

Nodes = LOI.Adventure.Script.Nodes

class LOI.Adventure.Interface.Text extends LOI.Adventure.Interface
  @register 'LandsOfIllusions.Adventure.Interface.Text'

  onCreated: ->
    super

    console.log "Text interface is being created." if LOI.debug

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
      interface: @
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

    console.log "Destroying text interface." if LOI.debug

    @commandInput.destroy()
    @dialogSelection.destroy()

  active: ->
    # The text interface is active unless there is an item active.
    not @options.adventure.activeItem()

  onLocationChanged: (location) ->
    @narrative?.clear()
      
  introduction: ->
    location = @location()
    return unless location
    
    if location.constructor.visited
      fullName = location.avatar.fullName()
      return unless fullName

      # We've already visited this location so simply return the full name.
      "#{_.upperFirst fullName}."

    else
      # It's the first time we're visiting this location in this session so show the full description.
      location.avatar.description()
      
  exits: ->
    exits = @location()?.state()?.exits
    return [] unless exits

    # Generate a unique set of IDs from all directions (some directions might lead to same location).
    _.uniq _.values exits

  exitName: ->
    exitLocationId = @currentData()
    location = @location()

    # Find exit's location name.
    subscriptionHandle = location.exitsTranslationSubscriptions()[exitLocationId]
    return unless subscriptionHandle?.ready()

    key = LOI.Avatar.translationKeys.shortName
    translated = AB.translate subscriptionHandle, key

    translated.text

  things: ->
    sorted = _.sortBy @location().things.values(), (thing) ->
      thing.state().displayOrder

    sorted

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

  activeItems: ->
    # Active items render their UI and can be any non-deactivated item in the inventory or at the location.
    items = _.flatten [
      @options.adventure.inventory.values()
      _.filter @options.adventure.currentLocation().things.values(), (thing) => thing instanceof LOI.Adventure.Item
    ]

    activeItems = _.filter items, (item) => not item.deactivated()

    console.log "Text interface is displaying active items", activeItems if LOI.debug

    activeItems

  inventoryItems: ->
    items = @options.adventure.inventory.values()

    console.log "Text interface is displaying inventory items", items if LOI.debug

    items

  showDescription: (thing) ->
    @narrative.addText thing.avatar?.description()
    
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
    @options.adventure.parser.parse command
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
      text = @_evaluateLine dialogLine

      @narrative.addText "> \"#{text.toUpperCase()}\""
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
      text = @_evaluateLine dialogLine

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

  _handleNarrativeLine: (narrativeLine) ->
    # Simply output the line to the narrative and move on.
    text = @_evaluateLine narrativeLine

    @narrative.addText text
    narrativeLine.end()

  _evaluateLine: (lineNode) ->
    lineNode.line.replace /`(.*?)`/g, (codeSection) ->
      expression = codeSection.match(/`(.*?)`/)[1]
      console.log "Evaluating embedded expression", expression, "from line", lineNode if LOI.debug

      # Create a code node to evaluate the expression.
      codeNode = new LOI.Adventure.Script.Nodes.Code
        expression: expression

      codeNode.script = lineNode.script

      # Evaluate the expression, but we don't allow (or at least react to) state changes within the expression.
      codeNode.evaluate
        triggerChange: false
