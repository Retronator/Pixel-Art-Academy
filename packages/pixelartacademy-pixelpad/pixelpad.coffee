AB = Artificial.Base
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.PixelPad extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.PixelPad'
  @url: -> 'pixelpad'

  @version: -> '0.2.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "PixelPad 2000"
  @shortName: -> "PixelPad"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's your morphing handheld computer, the latest PixelPad!
    "

  @storeDescription: -> "
    The brains behind the Retropolis company Pixel have done it again.
    The latest in their PixelPad handheld series is a marvel of engineering with a flexible display surface
    that resizes to your needs. Change it from a tablet to a smartphone, or wear it like a
    watch, PixelPad 2000 is your new best friend in your digital lifestyle.
  "

  @initialize()

  @PositioningType:
    ScreenCenter: 'screen-center'
    ScreenBottom: 'screen-bottom'

  constructor: ->
    super arguments...

    # PixelPad is always active to keep running apps, but we can show it or hide it.
    @activatedState LOI.Adventure.Item.ActivatedStates.Activated
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

    @fullscreen = new ReactiveField false

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
    super arguments...

    @overlay = @childComponentsOfType(LOI.Components.Overlay)[0]
    @backButton = @childComponentsOfType(LOI.Components.BackButton)[0]

    # Since we start activated, overlay will also be already activated, but it shouldn't be, so we deactivate it here.
    @overlay.onDeactivating()

    @$device = @$('.device')

    $(document).on 'mousemove.pixelartacademy-pixelpad', (event) => @onMouseMove event
    $(document).on 'mouseup.pixelartacademy-pixelpad', (event) => @onMouseUp event
    $(document).on 'keydown.pixelartacademy-pixelpad', (event) => @onKeyDown event

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
        $('body').addClass('pixelartacademy-pixelpad-resizing')

      else
        $('body').removeClass('pixelartacademy-pixelpad-resizing')

    @autorun =>
      size = @size()
      scale = LOI.adventure.interface.display.scale()
      viewport = LOI.adventure.interface.display.viewport()
      clientWidth = viewport.viewportBounds.width()
      clientHeight = viewport.viewportBounds.height()

      # Decide whether to center PixelPad or fix it to the bottom.
      pixelPadHeightRequirement = (size.height + 65 * 2) * scale

      @positioningClass if clientHeight < pixelPadHeightRequirement then @constructor.PositioningType.ScreenCenter else @constructor.PositioningType.ScreenBottom

      # Detect if size is covering the whole viewport width.
      @fullscreen size.width * scale >= clientWidth

  onDestroyed: ->
    super arguments...

    $(document).off('.pixelartacademy-pixelpad')
    $('body').removeClass('pixelartacademy-pixelpad-resizing')

  backButtonVisible: -> true # Override to control when the back button is available.
  
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
      @activatedState LOI.Adventure.Item.ActivatedStates.Activated

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

  backButtonVisibleClass: ->
    'visible' if @backButtonVisible()

  osStyle: ->
    'pointer-events': if @resizing() then 'none' else 'initial'

  resizable: ->
    @os.currentApp?()?.resizable()

  resizableClass: ->
    'resizable' if @resizable()

  fullscreenClass: ->
    'fullscreen' if @fullscreen()

  backButtonCallback: ->
    # We must return the callback function.
    => @os.backButtonCallback()

  events: ->
    super(arguments...).concat
      'mousedown .glass': @onMouseDownGlass
      'scroll .os': @onScrollOS

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
    
    # We need an explicit return, otherwise false would be returned from the call to resizing, which prevents bubbling.
    return

  onKeyDown: (event) ->
    # Don't capture events when the interface is busy.
    return if LOI.adventure.interface.busy()

    # Open the device with the alt key.
    return if @active()
    
    keyCode = event.which
    return unless keyCode is AC.Keys.alt

    @open()

  onScrollOS: (event) ->
    # Prevent scrolling of the OS content. This can happen despite
    # overflow: hidden if the browser tries to focus on input elements.
    event.currentTarget.scrollLeft = 0
    event.currentTarget.scrollTop = 0

  # Listener

  onCommand: (commandResponse) ->
    pixelPad = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], pixelPad.avatar]
      priority: 1
      action: => pixelPad.open()

  # Routing

  LOI.Adventure.registerDirectRoute "/#{@url()}/*", @pixelPadRouteHandler
  @pixelPadRouteHandler: =>
    # HACK: Remember which app we're trying to open.
    appUrl = AB.Router.getParameter('parameter2')
    appPath = AB.Router.getParameter('parameter3')
    appParameter = AB.Router.getParameter('parameter4')

    # Show the item if we need to.
    unless LOI.adventure.activeItemId() is @id()
      Tracker.autorun (computation) =>
        # Wait until the item is available.
        return unless pixelPad = LOI.adventure.getCurrentThing @
        computation.stop()

        # Show the item.
        pixelPad.open()
        
        # HACK: Force back the wanted app path.
        AB.Router.setParameters
          parameter1: @url()
          parameter2: appUrl
          parameter3: appPath
          parameter4: appParameter
