AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Interface.Text extends LOI.Interface
  @register 'LandsOfIllusions.Adventure.Interface.Text'

  things: ->
    return [] unless things = LOI.adventure.currentLocationThings()

    thing for thing in things when thing.displayInLocation()

  showCommandLine: ->
    # Show command line unless we're displaying a dialog.
    not @showDialogSelection()

  showDialogSelection: ->
    # Wait if we're paused.
    return if @waitingKeypress()

    # Show the dialog selection when we have some choices available.
    return unless options = @dialogSelection.dialogLineOptions()

    # After the new choices are re-rendered, scroll down the narrative.
    Tracker.afterFlush => @narrative.scroll()

    options

  activeDialogOptionClass: ->
    option = @currentData()

    'active' if option is @dialogSelection.selectedDialogLine()

  showInventory: ->
    not @inIntro() and @inventoryItems().length

  activeItems: ->
    # Active items render their UI and can be any non-deactivated item in the inventory or at the location.
    items = _.filter LOI.adventure.currentPhysicalThings(), (thing) => thing instanceof LOI.Adventure.Item

    activeItems = _.filter items, (item) => not item.deactivated()

    # Also add _id field to help #each not re-render things all the time.
    item._id = item.id() for item in items

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
    # The text interface is inactive when there are any modal dialogs.
    return if LOI.adventure.modalDialogs().length

    # It's inactive when there is an item active.
    return if LOI.adventure.activeItem()

    # It's also inactive when we're in any of the accounts-ui flows/dialogs.
    accountsUiSessionVariables = ['inChangePasswordFlow', 'inMessageOnlyFlow', 'resetPasswordToken', 'enrollAccountToken', 'justVerifiedEmail', 'justResetPassword', 'configureLoginServiceDialogVisible', 'configureOnDesktopVisible']
    for variable in accountsUiSessionVariables
      return if Accounts._loginButtonsSession.get variable

    true
    
  # Query this to see if the user is doing something with the interface.
  busy: ->
    busyConditions = [
      not LOI.adventure.interface.active()
      LOI.adventure.interface.waitingKeypress()
      LOI.adventure.interface.commandInput.command().length
      LOI.adventure.interface.showDialogSelection()
    ]

    _.some busyConditions
    
  # Use to get back to the initial state with full location description.
  resetInterface: ->
    @_lastNode null
    @_pausedNode null

    @narrative?.clear()

    @location().constructor.visited false
    @inIntro true

    @initializeIntroductionFunction()

    Tracker.afterFlush =>
      @narrative.scroll()

  stopIntro: (options = {}) ->
    options.scroll ?= true

    @inIntro false

    # Mark location as visited after the intro of the location is done.
    @location().state 'visited', true

    Tracker.afterFlush =>
      @resize()

      if options.scroll
        @scroll
          position: @maxScrollTop()
          animate: true

  ready: ->
    conditions = _.flattenDeep [
      avatar.ready() for avatar in @exitAvatars()
    ]

    _.every conditions

  events: ->
    super.concat
      'wheel': @onWheel
      'wheel .scrollable': @onWheelScrollable
      'mouseenter .command': @onMouseEnterCommand
      'mouseleave .command': @onMouseLeaveCommand
      'click .command': @onClickCommand
      'mouseenter .exits .exit .name': @onMouseEnterExit
      'mouseleave .exits .exit .name': @onMouseLeaveExit
      'click .exits .exit .name': @onClickExit
      'mouseenter .text-interface': @onMouseEnterTextInterface
      'mouseleave .text-interface': @onMouseLeaveTextInterface

  onMouseEnterCommand: (event) ->
    @hoveredCommand $(event.target).attr 'title'

  onMouseLeaveCommand: (event) ->
    @hoveredCommand null

  onClickCommand: (event) ->
    return if @waitingKeypress()

    @_executeCommand @hoveredCommand()
    @hoveredCommand null

  onMouseEnterExit: (event) ->
    @hoveredCommand "Go to #{$(event.target).text()}"

  onMouseLeaveExit: (event) ->
    @hoveredCommand null

  onClickExit: (event) ->
    return if @waitingKeypress()

    @_executeCommand @hoveredCommand()
    @hoveredCommand null

  onMouseEnterTextInterface: (event) ->
    # Make crosshair cursor animate.
    $textInterface = @$('.text-interface')
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
        $textInterface.addClass("cursor-frame-#{cursorFrame}")
        $textInterface.removeClass("cursor-frame-#{@_previousCursorFrame}")
        @_previousCursorFrame = cursorFrame
    ,
      175

  onMouseLeaveTextInterface: (event) ->
    Meteor.clearInterval @_crossHairAnimation
