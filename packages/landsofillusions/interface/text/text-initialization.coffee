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

    # Add 2x scale class to html so we can scale cursors.
    @autorun (computation) =>
      if @display.scale() is 2
        $('html').addClass('scale-2')

      else
        $('html').removeClass('scale-2')

    @narrative = new LOI.Interface.Components.Narrative
      textInterface: @

    @commandInput = new LOI.Interface.Components.CommandInput
      interface: @
      onEnter: => @onCommandInputEnter()

    @dialogSelection = new LOI.Interface.Components.DialogSelection
      interface: @
      onEnter: => @onDialogSelectionEnter()

    @hoveredCommand = new ReactiveField null

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
      @options.adventure.currentLocation()?.illustrationHeight?()

      Tracker.afterFlush =>
        @resize()

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
