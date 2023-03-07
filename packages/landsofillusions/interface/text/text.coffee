AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Interface.Text extends LOI.Interface
  @register 'LandsOfIllusions.Interface.Text'

  world: ->
    LOI.adventure.world

  exitAvatarName: ->
    exitAvatar = @currentData()

    # Show the text for back instead of location name for that direction.
    Back = LOI.Parser.Vocabulary.Keys.Directions.Back
    backExit = LOI.adventure.currentSituation()?.exits()[Back]

    return @parser.vocabulary.getPhrases(Back)?[0] if exitAvatar.thingClass.id() is backExit?.id()

    exitAvatar.shortName()

  things: ->
    return [] unless things = LOI.adventure.currentLocationThings()

    # Remove any externally hidden things. We need to get instances in case classes were added to the array.
    hiddenThings = for thing in @hiddenThings()
      LOI.adventure.getCurrentLocationThing thing

    things = _.difference things, hiddenThings

    thing for thing in things when thing.displayInLocation()

  thingDescription: ->
    # WARNING: The output of this function should be HTML escaped
    # since the results will be directly injected with triple braces.
    thing = @currentData()

    # Look for a special description.
    description = thing.descriptiveName()

    # If that's not available, just use the full name formatted as a sentence.
    description ?= "#{_.upperFirst thing.fullName()}."

    @_formatOutput description

  showCommandLine: ->
    # Show command line unless we're displaying a dialog.
    not @showDialogueSelection()

  showDialogueSelection: ->
    # Wait if we're paused.
    return if @waitingKeypress()

    # Show the dialog selection when we have some choices available.
    return unless options = @dialogueSelection.dialogueLineOptions()

    # After the new choices are re-rendered, scroll down the narrative.
    Tracker.afterFlush => @narrative.scroll()

    options

  activeDialogOptionClass: ->
    option = @currentData()

    'active' if option is @dialogueSelection.selectedDialogueLine()

  showInventory: ->
    not @inIntro() and @inventoryItems().length

  activeItems: ->
    # Active items render their UI and can be any non-deactivated item in the inventory or at the location.
    items = _.filter LOI.adventure.currentPhysicalThings(), (thing) => thing instanceof LOI.Adventure.Item

    activeItems = _.filter items, (item) => not item.deactivated()

    console.log "Text interface is displaying active items", activeItems if LOI.debug

    activeItems

  inventoryItems: ->
    return [] unless items = LOI.adventure.currentInventoryThings()

    items = (item for item in items when item.displayInInventory())

    console.log "Text interface is displaying inventory items", items if LOI.debug

    items

  showDescription: (thing) ->
    @narrative.addText thing.description()

  caretIdleClass: ->
    'idle' if @commandInput.idle()

  waitingKeypress: ->
    @_pausedNode() or @inIntro()

  # Query this to see if the interface is listening to user commands.
  active: ->
    # The text interface is inactive when adventure is paused.
    return if LOI.adventure.paused()

    # It's inactive when there is an item active.
    return if LOI.adventure.activeItem()

    true
    
  # Query this to see if the user is doing something with the interface.
  busy: ->
    busyConditions = [
      not LOI.adventure.interface.active()
      LOI.adventure.interface.waitingKeypress()
      LOI.adventure.interface.commandInput.command().length
      LOI.adventure.interface.showDialogueSelection()
    ]

    _.some busyConditions
    
  # Use to get back to the initial state with full location description.
  reset: (options = {}) ->
    options.resetIntroduction ?= true

    # Clear the current context.
    LOI.adventure.exitContext()

    @_lastNode null
    @_pausedNode null

    @narrative?.clear()

    if options.resetIntroduction
      @location()?.constructor.visited false

      # Show intro again (scrolls to top as well).
      @showIntro()

      @initializeIntroductionFunction()

    Tracker.afterFlush =>
      @narrative.scroll()

  showIntro: ->
    @inIntro true

    # Scroll after intro has updated and other elements were hidden.
    Tracker.afterFlush => @narrative.scroll animate: false

  stopIntro: (options = {}) ->
    options.scroll ?= true

    @inIntro false

    # Mark location as visited after the intro of the location is done.
    @location()?.state 'visited', true

    Tracker.afterFlush =>
      @resize()

      if options.scroll
        @scroll
          position: @maxScrollTop()
          animate: true
          
  listeners: ->
    @parser.listeners

  ready: ->
    return unless exitAvatars = @exitAvatars()
    
    conditions = _.flattenDeep [
      @parser.ready()
      avatar.ready() for avatar in exitAvatars
      subscription.ready() for subscription in @_actionTranslationSubscriptions
    ]

    _.every conditions

  commandBeforeCaret: ->
    # WARNING: The output of this function should be HTML escaped
    # since the results will be directly injected with triple braces.
    commandBeforeCaret = @commandInput.commandBeforeCaret()

    @_insertQuotedStringSpans commandBeforeCaret

  commandAfterCaret: ->
    # WARNING: The output of this function should be HTML escaped
    # since the results will be directly injected with triple braces.
    commandBeforeCaret = @commandInput.commandBeforeCaret()
    commandAfterCaret = @commandInput.commandAfterCaret()

    # See if we have an odd number of quotes in the before part.
    numberOfQuotesBefore = _.sumBy commandBeforeCaret, (character) => if character is '"' then 1 else 0
    hangingQuote = numberOfQuotesBefore % 2

    # Close the quotes if all together there are an odd number of quotes.
    numberOfQuotesAfter = _.sumBy commandAfterCaret, (character) => if character is '"' then 1 else 0
    if (numberOfQuotesBefore + numberOfQuotesAfter) % 2
      commandAfterCaret += '"'

    @_insertQuotedStringSpans commandAfterCaret, hangingQuote

  _insertQuotedStringSpans: (string, hangingQuote) ->
    # NOTE: The output of this function is HTML escaped and can be used directly injected with triple braces.
    result = ''

    # Open span at the start since we need to return self-contained valid html.
    result += "<span class='quoted-string'>" if hangingQuote

    for character in string
      if character is '"'
        if hangingQuote
          # Close the hanging quote.
          result += "</span>&quot;"

        else
          # Open the quote span.
          result += "&quot;<span class='quoted-string'>"

        hangingQuote = not hangingQuote

      else
        result += AM.HtmlHelper.escapeText character

    # Close span at the end since we need to return self-contained valid html.
    result += "</span>" if hangingQuote

    result

  capturePaste: (handler) ->
    @_pasteCaptureHandler = handler
    @$('.dummy-input').focus()

    # Remove it if it doesn't get immediately handled (for example, if dummy input was not focused).
    Meteor.setTimeout =>
      @_pasteCaptureHandler = null
    ,
      100

  events: ->
    super(arguments...).concat
      'wheel': @onWheel
      'wheel .scrollable': @onWheelScrollable
      'mouseenter .command': @onMouseEnterCommand
      'mouseleave .command': @onMouseLeaveCommand
      'click .ui-area': @onClickUIArea
      'click .command': @onClickCommand
      'click .location': @onClickLocation
      'mouseenter .exits .exit .name': @onMouseEnterExit
      'mouseleave .exits .exit .name': @onMouseLeaveExit
      'click .exits .exit .name': @onClickExit
      'mouseenter .landsofillusions-interface-text': @onMouseEnterTextInterface
      'mouseleave .landsofillusions-interface-text': @onMouseLeaveTextInterface
      'input .dummy-input': @onInputDummyInput
      'mouseenter .dialog-selection .option': @onMouseEnterDialogSelectionOption
      'click .dialog-selection .option': @onClickDialogSelectionOption

  onMouseEnterCommand: (event) ->
    @hoveredCommand $(event.target).attr 'title'

  onMouseLeaveCommand: (event) ->
    @hoveredCommand null

  onClickUIArea: (event) ->
    # When we're waiting for user interaction, clicking on the bottom UI part doubles for pressing enter.
    if @waitingKeypress()
      @onCommandInputEnter()

      # Do not let others handle this event.
      event.stopPropagation()

  onClickCommand: (event) ->
    return if @waitingKeypress()

    @_executeCommand @hoveredCommand()
    @hoveredCommand null

  onClickLocation: (event) ->
    return if @waitingKeypress()

    # See if hovering pre-filled a command for us.
    if suggestedCommand = @suggestedCommand()
      @_executeCommand suggestedCommand
      return

    # No command was given. If we have a character and the click was inside the scene, we can move the character.
    return unless characterId = LOI.characterId()
    return unless cursorIntersectionPoints = LOI.adventure.world.cursorIntersectionPoints()
    return unless cursorIntersectionPoints.length

    # Create move memory action.
    type = LOI.Memory.Actions.Move.type
    situation = LOI.adventure.currentSituationParameters()

    LOI.Memory.Action.do type, characterId, situation,
      coordinates: _.last(cursorIntersectionPoints).point.toObject()

  onMouseEnterExit: (event) ->
    exitAvatar = @currentData()

    # Show just "go back" instead of "go to back".
    Back = LOI.Parser.Vocabulary.Keys.Directions.Back
    backExit = LOI.adventure.currentSituation().exits()[Back]

    if exitAvatar.thingClass.id() is backExit?.id()
      command = "Go #{$(event.target).text()}"
      
    else
      command = "Go to #{$(event.target).text()}"

    @hoveredCommand command

  onMouseLeaveExit: (event) ->
    @hoveredCommand null

  onClickExit: (event) ->
    return if @waitingKeypress()

    @_executeCommand @hoveredCommand()
    @hoveredCommand null

  onMouseEnterTextInterface: (event) ->
    # Make crosshair cursor animate.
    $textInterface = @$('.landsofillusions-interface-text')
    cursorTimeFrame = 0

    # Just to make sure, clear any leftover animations.
    Meteor.clearInterval @_crossHairAnimation

    # Start new animation.
    @_crossHairAnimation = Meteor.setInterval =>
      # Advance cursor
      cursorTimeFrame++
      cursorTimeFrame = 0 if cursorTimeFrame is 5

      cursorFrame = 1 if cursorTimeFrame < 3
      cursorFrame = 2 if cursorTimeFrame is 3
      cursorFrame = 3 if cursorTimeFrame is 4

      unless cursorFrame is @_previousCursorFrame
        $textInterface?.addClass("cursor-frame-#{cursorFrame}")
        $textInterface?.removeClass("cursor-frame-#{@_previousCursorFrame}")
        @_previousCursorFrame = cursorFrame
    ,
      175

  onMouseLeaveTextInterface: (event) ->
    Meteor.clearInterval @_crossHairAnimation

  onInputDummyInput: (event) ->
    $dummyInput = $(event.target)
    value = $dummyInput.val()

    if @_pasteCaptureHandler
      # Report the pasted text to the caller.
      @_pasteCaptureHandler value
      @_pasteCaptureHandler = null

    # Clear the content so we don't contaminate further pastes.
    $dummyInput.val ''

  onMouseEnterDialogSelectionOption: (event) ->
    option = @currentData()
    @dialogueSelection.selectDialogLineOption option

  onClickDialogSelectionOption: (event) ->
    option = @currentData()
    @dialogueSelection.selectDialogLineOption option
    @dialogueSelection.confirm()
