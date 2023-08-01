AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Interface.Text extends LOI.Interface.Text
  onCreated: ->
    super arguments...

    console.log "Text interface is being created." if LOI.debug

    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 240
      maxDisplayWidth: 480
      maxDisplayHeight: 640
      minScale: LOI.settings.graphics.minimumScale.value
      maxScale: LOI.settings.graphics.maximumScale.value
      minAspectRatio: 1 / 2
      maxAspectRatio: 2
      debug: false
      
    @illustrationSize = new AE.Rectangle

    @narrative = new LOI.Interface.Components.Narrative
      textInterface: @

    @commandInput = new LOI.Interface.Components.CommandInput
      interface: @
      onEnter: => @onCommandInputEnter()

    @dialogueSelection = new LOI.Interface.Components.DialogueSelection
      interface: @
      onEnter: => @onDialogueSelectionEnter()

    @hoveredCommand = new ReactiveField null

    @suggestedCommand = new ComputedField =>
      # If we're hovering a command in the narrative, show that.
      hoveredCommand = @hoveredCommand()
      return hoveredCommand if hoveredCommand

      # See if we're hovering an avatar in the world.
      return unless avatar = LOI.adventure.world.avatarUnderCursor()

      # See if the avatar belongs to a thing.
      thing = _.find LOI.adventure.currentPhysicalThings(), (thing) => thing.avatar is avatar
      target = thing or avatar

      # See if we have a descriptive name.
      if descriptiveName = target.descriptiveName()
        # See if there is a command in the description.
        if match = descriptiveName.match /!\[(.*?)]\((.*?)\)/
          # The second capture group contains the command.
          return match[2]

      # We couldn't get a full command so just write the avatar name.
      target.fullName()

    @inIntro = new ReactiveField false

    @uiInView = new ReactiveField false

    @minimapSize = new ReactiveField null

    @exitAvatars = new ComputedField =>
      return unless currentSituation = LOI.adventure.currentSituation()

      LOI.adventure.getAvatar exit for exitId, exit of currentSituation.exitsById()

    # Allow to hide specific things from running scripts.
    @hiddenThings = new ReactiveField []
    
    # Subscribe to all action translations.
    actionTypes = LOI.Memory.Action.getTypes()
    
    @_actionTranslationSubscriptions = for actionType in actionTypes
      AB.subscribeNamespace actionType
  
    @parser = new LOI.Parser
  
    # Node handling must get initialized before handlers, since the latter depends on it.
    @initializeNodeHandling()
    @initializeHandlers()

  onRendered: ->
    super arguments...

    console.log "Rendering text interface." if LOI.debug

    @initializeScrolling()

    # Resize on viewport, fullscreen, and illustration changes.
    @_illustration = new ComputedField =>
      LOI.adventure.currentSituation()?.illustration()
    ,
      EJSON.equals

    @autorun (computation) =>
      @display.viewport()
      AM.Window.isFullscreen()
      @_illustration()

      Tracker.afterFlush =>
        @resize()

    @autorun (computation) =>
      # Show the hint if the player needs to press enter.
      return unless @waitingKeypress()

      # Clear any previously set timeouts.
      Meteor.clearTimeout @_keypressHintTimetout

      # We need to manually add the hint visible class so that transition kicks in.

      # Hide hint if already present.
      @$('.command-line .keypress-hint').removeClass('visible')

      # Show the hint after a delay, so that the player has time to read the text before they are prompted.
      lines = @narrative.lines()
      if lines.length
        targetText = _.last lines

      else
        targetText = @introduction()

        # Wait some more if the introduction text hasn't been loaded yet.
        return unless targetText

      # Average reading time is about 1000 characters per minute, or 17 per second.
      readTime = targetText.length / 17

      # We also add in a delay of 2s so we don't annoy the player.
      hintDelayTime = readTime + 2

      @_keypressHintTimetout = Meteor.setTimeout =>
        @$('.command-line .keypress-hint').addClass('visible')
      ,
        hintDelayTime * 1000

    # Prepare location loading cover.
    @$locationLoadingCover = @$('.location .loading-cover')
    @$locationLoadingCover.css(height: '100%')
    @$locationLoadingCaption = @$locationLoadingCover.find('.caption')

  onDestroyed: ->
    super arguments...

    console.log "Destroying text interface." if LOI.debug

    @commandInput.destroy()
    @dialogueSelection.destroy()

    $(window).off '.landsofillusions-interface-text'

    # Clean up body height that was set from resizing.
    $('body').css height: ''

    # Clean up overflow hidden on html from scrolling wheel detection.
    $('html').css overflow: ''

    subscription.stop() for subscription in @_actionTranslationSubscriptions
