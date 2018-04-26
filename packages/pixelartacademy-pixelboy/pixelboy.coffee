AB = Artificial.Base
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.PixelBoy extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.PixelBoy'
  @url: -> 'pixelboy'

  @version: -> '0.2.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "PixelBoy 2000"
  @shortName: -> "PixelBoy"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's your morphing handheld computer, the latest PixelBoy!
    "

  @storeDescription: -> "
    The brains behind the Retropolis company Pixel have done it again.
    The latest in their PixelBoy handheld series is a marvel of engineering with a flexible display surface
    that resizes to your needs. Change it from a tablet to a smartphone, or wear it like a
    watch, PixelBoy 2000 is your new best friend in your digital lifestyle.
  "

  @initialize()

  @PositioningType:
    ScreenCenter: 'screen-center'
    ScreenBottom: 'screen-bottom'

  constructor: ->
    super

    # PixelBoy is always active to keep running apps, but we can show it or hide it.
    @activatedState LOI.Adventure.Item.activatedStates.Activated
    @active = new ReactiveField false
    @fullscreenOverlay = new ReactiveField false

    # We create the OS instance and send ourselves to it so it knows it's running embedded.
    @os = new @constructor.OS @

    # The desired current width and height of the physical device (measured as the inner screen/OS area).
    @size = new ReactiveField
      width: 0
      height: 0
    ,
      EJSON.equals

    # The actual width and height as animated by velocity.
    @animatingSize = new ReactiveField
      width: 0
      height: 0
    ,
      EJSON.equals

    @resizing = new ReactiveField false

    @startResizeX = new ReactiveField null
    @startResizeY = new ReactiveField null

    @startWidth = new ReactiveField null
    @startHeight = new ReactiveField null

    @endResizeX = new ReactiveField null
    @endResizeY = new ReactiveField null

    @positioningClass = new ReactiveField null

  onRendered: ->
    super

    @overlay = @childComponentsOfType(LOI.Components.Overlay)[0]
    @backButton = @childComponentsOfType(LOI.Components.BackButton)[0]

    # Since we start activated, overlay will also be already activated, but it shouldn't be, so we deactivate it here.
    @overlay.onDeactivating()

    @$device = @$('.device')

    $(document).on 'mousemove.pixelartacademy-pixelboy', (event) => @onMouseMove event
    $(document).on 'mouseup.pixelartacademy-pixelboy', (event) => @onMouseUp event
    $(document).on 'keydown.landsofillusions-items-sync', (event) => @onKeyDown event

    # Reset scale to 0 to trigger direct setting of size.
    @_lastScale = 0

    # Perform automatic resizing, based on current app desires.
    @autorun =>
      return unless app = @os.currentApp()

      size = @size()
      newWidth = size.width
      newHeight = size.height

      # Bound it to min/max size of the app.
      newWidth = Math.min app.maxWidth(), newWidth if app.maxWidth()
      newWidth = Math.max app.minWidth(), newWidth if app.minWidth()

      newHeight = Math.min app.maxHeight(), newHeight if app.maxHeight()
      newHeight = Math.max app.minHeight(), newHeight if app.minHeight()

      Tracker.nonreactive =>
        # Set the new size values.
        @size
          width: newWidth
          height: newHeight

    # Handle manual resizing from user input.
    @autorun =>
      return unless @resizing()

      scale = LOI.adventure.interface.display.scale()
      heightFactor = if @positioningClass() is @constructor.PositioningType.ScreenBottom then 1 else 2

      # Calculate desired state based on dragging.
      newWidth = @startWidth() + (@endResizeX() - @startResizeX()) * 2 / scale
      newHeight = @startHeight() - (@endResizeY() - @startResizeY()) * heightFactor / scale

      # Set the new size values.
      @size
        width: newWidth
        height: newHeight

    # Animate the size using velocity.
    @autorun =>
      size = @size()
      scale = LOI.adventure.interface.display.scale()

      # If scale has changed, directly set the new size without animations.
      unless scale is @_lastScale
        @$device.css
          width: size.width * scale
          height: size.height * scale

        @animatingSize size
        @_lastSize = size
        @_lastScale = scale
        return

      startSize =
        width: @$device.width() / scale
        height: @$device.height() / scale

      @$device.velocity('stop', true).velocity
        width: size.width * scale
        height: size.height * scale
        tween: 1
      ,
        duration: if @resizing() then 100 else 1000
        easing: if @resizing() then 'easeOutCirc' else 'easeInOutQuint'
        progress: (elements, complete, remaining, start, tweenValue) =>
          @animatingSize
            width: startSize.width + (size.width - startSize.width) * tweenValue
            height: startSize.height + (size.height - startSize.height) * tweenValue

        complete: =>
          @animatingSize size

    # Add resizing class to body to force cursor change no matter where we move.
    @autorun =>
      if @resizing()
        $('body').addClass('pixelartacademy-pixelboy-resizing')

      else
        $('body').removeClass('pixelartacademy-pixelboy-resizing')

    # Decide whether to center PixelBoy or fix it to the bottom.
    @autorun =>
      size = @size()
      scale = LOI.adventure.interface.display.scale()
      clientHeight = @$('.max-area').height()

      pixelBoyHeightRequirement = (size.height + 35 * 2) * scale

      @positioningClass if clientHeight < pixelBoyHeightRequirement then @constructor.PositioningType.ScreenCenter else @constructor.PositioningType.ScreenBottom

  onDestroyed: ->
    super

    $(document).off('.pixelartacademy-pixelboy')
    $('body').removeClass('pixelartacademy-pixelboy-resizing')
    
  url: -> @os.url()

  open: ->
    LOI.adventure.goToItem @
    @fullscreenOverlay true

    # Wait until we're rendered.
    Tracker.nonreactive =>
      Tracker.autorun (computation) =>
        return unless @isRendered()
        computation.stop()

        # We manually trigger overlay's transition since our active state is already activated.
        @overlay.onActivating()

  onActivate: (finishedDeactivatingCallback) ->
    # Bring in the device.
    @active true
    finishedDeactivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    # Start hiding the device.
    @active false

    Meteor.setTimeout =>
      # Hide the fullscreen overlay, but leave the device active.
      @fullscreenOverlay false
      @activatedState LOI.Adventure.Item.activatedStates.Activated

      # We manually trigger overlay's transition since our active state is already activated.
      @overlay.onDeactivated()

      # We also reset the back button.
      @backButton.closing false
    ,
      500

  activeClass: ->
    return unless @isRendered()

    'active' if @active()

  visibleClass: ->
    # We need to show the content together with the fullscreen overlay.
    'visible' if @fullscreenOverlay()

  osStyle: ->
    'pointer-events': if @resizing() then 'none' else 'initial'

  resizable: ->
    @os.currentApp?()?.resizable()

  resizableClass: ->
    'resizable' if @resizable()

  backButtonCallback: ->
    # We must return the callback function.
    => @os.backButtonCallback()

  events: ->
    super.concat
      'mousedown .glass': @onMouseDownGlass

  onMouseDownGlass: (event) ->
    return unless @resizable()

    # Do not let text selection happen.
    event.preventDefault()

    # Get current x and y position.
    @startResizeX event.clientX
    @startResizeY event.clientY

    @endResizeX event.clientX
    @endResizeY event.clientY

    size = @size()
    @startWidth size.width
    @startHeight size.height

    @resizing true

  onMouseMove: (event) ->
    return unless @resizing()

    @endResizeX event.clientX
    @endResizeY event.clientY

  onMouseUp: (event) ->
    @resizing false

  onKeyDown: (event) ->
    # Don't capture events when interface is not active.
    return unless LOI.adventure.interface.active()

    keyCode = event.which
    return unless keyCode is AC.Keys.alt

    @open()

  # Listener

  onCommand: (commandResponse) ->
    pixelBoy = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], pixelBoy.avatar]
      priority: 1
      action: => pixelBoy.open()

  # Routing

  LOI.Adventure.registerDirectRoute "/#{@url()}/*", =>
    # HACK: Remember which app we're trying to open.
    appUrl = AB.Router.getParameter('parameter2')
    appPath = AB.Router.getParameter('parameter3')

    # Show the item if we need to.
    unless LOI.adventure.activeItemId() is @id()
      Tracker.autorun (computation) =>
        # Wait until the item is available.
        return unless pixelBoy = LOI.adventure.getCurrentThing @
        computation.stop()

        # Show the item.
        pixelBoy.open()
        
        # HACK: Force back the wanted app path.
        AB.Router.setParameters
          parameter1: @url()
          parameter2: appUrl
          parameter3: appPath
