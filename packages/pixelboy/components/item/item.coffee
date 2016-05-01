AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelBoy.Components.Item extends AM.Component
  @register "PixelArtAcademy.PixelBoy.Components.Item"

  constructor: (@pixelBoy) ->
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

    $(window).on('mousemove.pixelboy', (event) => @onMouseMove(event))
    $(window).on('mouseup.pixelboy', (event) => @onMouseUp(event))

    # Perform automatic resizing, based on current app desires.
    @autorun =>
      app = @pixelBoy.os.currentApp()

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

      scale = @pixelBoy.adventure.display.scale()

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
      scale = @pixelBoy.adventure.display.scale()

      # Don't animate, just set on first go.
      unless @initialSizeSet
        @$('.pixelboy').css
          width: size.width * scale
          height: size.height * scale

        @initialSizeSet = true
        return

      @$('.pixelboy').velocity('stop', true).velocity
        width: size.width * scale
        height: size.height * scale
      ,
        duration: if @resizing() then 100 else 1000
        easing: if @resizing() then 'easeOutCirc' else 'easeInOutQuint'

    # Add resizing class to body to force cursor.
    @autorun =>
      if @resizing()
        $('body').addClass('pixelboy-resizing')

      else
        $('body').removeClass('pixelboy-resizing')

    # Decide whether to center PixelBoy or fix it to the bottom.
    @autorun =>
      size = @size()
      scale = @pixelBoy.adventure.display.scale()
      clientHeight = AM.Window.clientBounds().height()

      pixelBoyHeightRequirement = (size.height + 35 * 2) * scale

      @positioningClass if clientHeight < pixelBoyHeightRequirement then 'screen-center' else 'screen-bottom'

  onDestroyed: ->
    super

    $(window).off('.pixelboy')
    $('body').removeClass('pixelboy-resizing')

  $pixelboy: ->
    @$('.pixelboy')

  activatedClass: ->
    'activated' if @pixelBoy.activating() or @pixelBoy.activated()

  osStyle: ->
    'pointer-events': if @resizing() then 'none' else 'initial'

  resizableClass: ->
    'resizable' if @pixelBoy.os.currentApp?()?.resizable()

  events: ->
    super.concat
      'click .hand': @onClickHand
      'mousedown .glass': @onMouseDownGlass

  onMouseDownGlass: (event) ->
    return unless @pixelBoy.os.currentApp?()?.resizable()
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

  onClickHand: (event) ->
    @pixelBoy.deactivate()

  draw: (appTime) ->
    # Any component based draw routines can go here.
