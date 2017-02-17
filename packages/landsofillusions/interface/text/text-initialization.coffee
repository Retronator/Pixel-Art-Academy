AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Interface.Text extends LOI.Interface.Text
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
      minAspectRatio: 1 / 2
      maxAspectRatio: 2
      debug: false

    @narrative = new LOI.Interface.Components.Narrative
      textInterface: @

    @commandInput = new LOI.Interface.Components.CommandInput
      interface: @
      onEnter: => @onCommandInputEnter()

    @dialogSelection = new LOI.Interface.Components.DialogSelection
      interface: @
      onEnter: => @onDialogSelectionEnter()

    @hoveredCommand = new ReactiveField null

    @inIntro = new ReactiveField false

    @uiInView = new ReactiveField false

    # Node handling must get initialized before handlers, since the latter depends on it.
    @initializeNodeHandling()
    @initializeHandlers()

  onRendered: ->
    super

    console.log "Rendering text interface." if LOI.debug

    @initializeScrolling()

    # Resize on viewport, fullscreen, and illustration height changes.
    @autorun =>
      @display.viewport()
      AM.Window.isFullscreen()
      LOI.adventure.currentLocation()?.illustrationHeight?()

      Tracker.afterFlush =>
        @resize()

    @autorun (computation) =>
      # Show the hint if the player needs to press enter.
      return unless @waitingKeypress()

      # Clear any previously set timeouts.
      Meteor.clearTimeout @_keypressHintTimetout

      # We need to manually add the hint visible class so that transition kicks in.
      lines = @narrative.lines()
      if lines.length
        # Hide hint if already present.
        @$('.command-line .keypress-hint').removeClass('visible')

        # Show the hint after a delay, so that the player has time to read the text before they are prompted.
        lastNarrativeLine = _.last lines

        # Average reading time is about 1000 characters per minute, or 17 per second.
        readTime = lastNarrativeLine.length / 17

        # We also add in a delay of 2s so we don't annoy the player.
        hintDelayTime = readTime + 2

        @_keypressHintTimetout = Meteor.setTimeout =>
          @$('.command-line .keypress-hint').addClass('visible')
        ,
          hintDelayTime * 1000

  onDestroyed: ->
    super

    console.log "Destroying text interface." if LOI.debug

    @commandInput.destroy()
    @dialogSelection.destroy()

    $(window).off '.text-interface'

    # Clean up body height that was set from resizing.
    $('body').css height: ''

    # Clean up overflow hidden on html from scrolling wheel detection.
    $('html').css overflow: ''
