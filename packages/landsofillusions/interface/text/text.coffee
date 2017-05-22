AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Interface.Text extends LOI.Interface
  @register 'LandsOfIllusions.Adventure.Interface.Text'

  introduction: ->
    location = @location()
    return unless location

    if currentIntroductionFunction = @_currentIntroductionFunction()
      introduction = currentIntroductionFunction()
      return @_formatOutput introduction

    if location.constructor.visited()
      fullName = location.avatar.fullName()
      return unless fullName

      # We've already visited this location so simply return the full name.
      "#{_.upperFirst fullName}."

    else
      # It's the first time we're visiting this location in this session so show the full description.
      situation = LOI.adventure.currentSituation()

      @_formatOutput situation.description.last()
      
  exitAvatars: ->
    # TODO: Get exits from current situation so they can be dynamically modified.
    exitAvatarsByLocationId = @location()?.exitAvatarsByLocationId()
    return [] unless exitAvatarsByLocationId

    # Generate a unique set of IDs from all directions (some directions might lead to same location).
    exitAvatars = _.values exitAvatarsByLocationId

    console.log "Displaying exits", exitAvatars if LOI.debug

    exitAvatars

  exitAvatarName: ->
    exitAvatar = @currentData()

    # Show the text for back instead of location name for that direction.
    Back = LOI.Parser.Vocabulary.Keys.Directions.Back
    backExit = LOI.adventure.currentSituation().exits()[Back]

    return LOI.adventure.parser.vocabulary.getPhrases(Back)?[0] if exitAvatar.options.id() is backExit?.id()

    exitAvatar.shortName()

  things: ->
    return [] unless things = LOI.adventure.currentLocationThings()

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

  narrativeLine: ->
    # WARNING: The output of this function should be HTML escaped
    # since the results will be directly injected with triple braces.
    lineText = @currentData()

    @_formatOutput lineText
    
  _formatOutput: (text) ->
    # NOTE: The output of this function is HTML escaped and can be used directly injected with triple braces.
    return unless text

    # We could have direct HTML in the text, so we need to collect it here, to replace it back instead of the escaped
    # versions. We have to trust that the provided HTML is already escaped and malicious free.
    htmlParts = text.match /%%html.*html%%/g

    text = AM.HtmlHelper.escapeText text

    # Replace back the html parts.
    for htmlPart in htmlParts or []
      # Extract the html content with a capture group.
      html = htmlPart.match(/%%html(.*)html%%/)[1]

      # Because we don't use global match flag, replacements will happen one by one in order.
      text = text.replace /%%html.*html%%/, html

    # Create color spans.
    text = text.replace /%%c(\d+)-([-\d]+)%(.*?)c%%/g, (match, hue, shade, text) ->
      hue = parseInt hue
      shade = parseInt shade

      colorHexString = LOI.Avatar.colorObject(hue: hue, shade: shade).getHexString()

      "<span style='color: ##{colorHexString}' data-hue='#{hue}' data-shade='#{shade}'>#{text}</span>"

    # Create text transform spans.
    text = text.replace /%%t([L|U])(.*?)t%%/g, (match, transformType, text) =>
      switch transformType
        when 'L' then transform = 'lowercase'
        when 'U' then transform = 'uppercase'

      "<span style='text-transform: #{transform}'>#{text}</span>"

    # Extract commands from image notation.
    text = text.replace /!\[(.*?)]\((.*?)\)/g, (match, text, command) ->
      command = text unless command.length
      "<span class='command' title='#{command}'>#{text}<span class='underline'></span><span class='background'></span></span>"

    Tracker.afterFlush =>
      # Add colors to commands.
      commands = @$('.narrative .command')
      return unless commands

      for element in commands
        $command = $(element)
        colorParent = $command.parent('*[data-hue]')

        if colorParent.length
          hue = colorParent.data 'hue'
          shade = colorParent.data 'shade'
          colorHexString = LOI.Avatar.colorObject(hue: hue, shade: shade + 1).getHexString()

          $command.css color: "##{colorHexString}"

          $command.find('.underline').css borderBottomColor: "##{colorHexString}"

          $command.find('.background').css backgroundColor: "##{colorHexString}"

    text

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
