AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Pico8 extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Desktop.Pico8'

  constructor: (@options) ->
    super

    @active = new ReactiveField false

    @dragging = new ReactiveField false
    @positionOffset = new ReactiveField x: 0, y: 0

  onCreated: ->
    super

    @display = @callAncestorWith 'display'

    @cartridge = new ComputedField =>
      return unless asset = @options.asset()
      asset.project.pico8Cartridge

    @device = new PAA.Pico8.Device.Handheld
      # Relay input/output calls to the cartridge.
      onInputOutput: (address, value) =>
        @cartridge()?.onInputOutput? address, value

    @autorun (computation) =>
      return unless cartridge = @cartridge()
      return unless game = cartridge.game()

      @device.loadGame game, @options.asset().project.projectId

  activeClass: ->
    'active' if @active()

  draggingClass: ->
    'dragging' if @dragging()

  positionStyle: ->
    return unless @active()

    offset = @positionOffset()

    right: "calc(50% - #{160 + offset.x}rem)"
    bottom: "calc(50% - #{77 + offset.y}rem)"

  events: ->
    super.concat
      'click': @onClick
      'mousedown': @onMouseDown

  onClick: (event) ->
    # Don't handle the click right after we've been deactivated from dragging.
    if @_draggingDeactivated
      @_draggingDeactivated = false
      return

    return if @active()

    @positionOffset x: 0, y: 0
    @active true

  onMouseDown: (event) ->
    return unless @active()

    # Only react to clicks directly on the case or screen.
    $target = $(event.target)
    return unless $target.hasClass('pixelartacademy-pico8-device-handheld') or $target.closest('.screen').length

    @dragging true
    @_moved = false

    @_mousePosition =
      x: event.clientX
      y: event.clientY

    # Wire end of dragging on mouse up anywhere in the window.
    $(document).on "mouseup.pixelartacademy-pixelboy-apps-drawing-editor-desktop-pico8", (event) =>
      $(document).off '.pixelartacademy-pixelboy-apps-drawing-editor-desktop-pico8'

      @dragging false

      # Close PICO-8 if we haven't moved.
      if not @_moved
        @_draggingDeactivated = true
        @active false

    $(document).on "mousemove.pixelartacademy-pixelboy-apps-drawing-editor-desktop-pico8", (event) =>
      @_moved = true
      scale = @display.scale()

      dragDelta =
        x: (event.clientX - @_mousePosition.x) / scale
        y: (event.clientY - @_mousePosition.y) / scale

      offset = @positionOffset()
      @positionOffset
        x: offset.x + dragDelta.x
        y: offset.y + dragDelta.y

      @_mousePosition =
        x: event.clientX
        y: event.clientY
