LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.PixelBoy'

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

  constructor: ->
    super

    # We create the OS instance and send ourselves to it so it knows it's running embedded.
    @os = new @constructor.OS @

    # The actual current width and height of the physical device (measured as the inner screen/OS area).
    @size = new ReactiveField
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

    @$device = @$('.device')

    $(window).on('mousemove.pixelartacademy-pixelboy', (event) => @onMouseMove event)
    $(window).on('mouseup.pixelartacademy-pixelboy', (event) => @onMouseUp event)

    # Perform automatic resizing, based on current app desires.
    @autorun =>
      app = @os.currentApp()

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

      # Calculate desired state based on dragging.
      newWidth = @startWidth() + (@endResizeX() - @startResizeX()) * 2 / scale
      newHeight = @startHeight() - (@endResizeY() - @startResizeY()) / scale

      # Set the new size values.
      @size
        width: newWidth
        height: newHeight

    # Animate the size using velocity.
    @autorun =>
      size = @size()
      scale = LOI.adventure.interface.display.scale()

      # Don't animate, just set on first go.
      unless @initialSizeSet
        @$device.css
          width: size.width * scale
          height: size.height * scale

        @initialSizeSet = true
        return

      @$device.velocity('stop', true).velocity
        width: size.width * scale
        height: size.height * scale
      ,
        duration: if @resizing() then 100 else 1000
        easing: if @resizing() then 'easeOutCirc' else 'easeInOutQuint'

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

      @positioningClass if clientHeight < pixelBoyHeightRequirement then 'screen-center' else 'screen-bottom'

  onDestroyed: ->
    super

    $(window).off('.pixelartacademy-pixelboy')
    $('body').removeClass('pixelartacademy-pixelboy-resizing')

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  activatedClass: ->
    'activated' if @activatable.activating() or @activatable.activated()

  osStyle: ->
    'pointer-events': if @resizing() then 'none' else 'initial'

  resizable: ->
    @os.currentApp?()?.resizable()

  resizableClass: ->
    'resizable' if @resizable()

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
