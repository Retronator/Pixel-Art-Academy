AB = Artificial.Babel
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
        # Resume dialog on any key press.
        pausedDialogLine = @_pausedDialogLine()
        if pausedDialogLine
          @_pausedDialogLine null

          pausedDialogLine.end()
          @commandInput.clear()
          return

        command = @commandInput.command().trim()
        return unless command.length

        @narrative.addText "> #{command.toUpperCase()}"
        @adventure.parser.parse command
        @commandInput.clear()

      onKeyDown: =>
        # Scroll to bottom on key press.
        @narrative.scroll()
        
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

  _handleDialogLine: (dialogLine) ->
    @narrative.addText "#{dialogLine.actor.name} says: \"#{dialogLine.line}\""

    if dialogLine.next
      # Let the user know there is more dialog and wait for their command to continue it.
      @_pausedDialogLine dialogLine

    else
      # We're done with this text so finish it.
      dialogLine.end()
      
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
