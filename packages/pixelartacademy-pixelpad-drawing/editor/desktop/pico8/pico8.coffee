AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Pico8 extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Pico8'
  @register @id()

  @template: -> @constructor.id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    # Loaded from the PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop namespace.
    subNamespace: true
    variables:
      handheldDragLong: AEc.ValueTypes.Trigger
      handheldDragTiny:
        valueType: AEc.ValueTypes.Trigger
        throttle: 100

  constructor: ->
    super arguments...

    @active = new ReactiveField false

    @dragging = new ReactiveField false
    @positionOffset = new ReactiveField x: 0, y: 0

  onCreated: ->
    super arguments...
    
    @app = @ancestorComponentOfType Artificial.Base.App
    @app.addComponent @
    
    @_dragTimeLeft = 0
    
    @desktop = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop
    @display = @callAncestorWith 'display'

    @cartridge = new ComputedField =>
      return unless asset = @desktop.activeAsset()
      asset.project?.pico8Cartridge

    @device = new PAA.Pico8.Device.Handheld
      # Relay input/output calls to the cartridge.
      onInputOutput: (address, value) =>
        @cartridge()?.onInputOutput? address, value
        
      # Enable device interface when the editor is active.
      enabled: => @desktop.active()

    @autorun (computation) =>
      return unless cartridge = @cartridge()
      return unless game = cartridge.game()

      @device.loadGame game, @desktop.activeAsset().project.projectId
    
    # Drag handheld when activating and deactivating.
    Tracker.triggerOnDefinedChange @active, =>
      @audio.handheldDragLong()
      @_lastAudioDragTime = Date.now()
      
      @_dragTimeLeft = 1
      
  onRendered: ->
    super arguments...
    
    @_pico8 = $('.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pico8')[0]
    
  onDestroyed: ->
    super arguments...

    @device.stop()

  activeClass: ->
    'active' if @active()

  draggingClass: ->
    'dragging' if @dragging()

  positionStyle: ->
    return unless @active()

    offset = @positionOffset()

    right: "calc(50% - #{160 + offset.x}rem)"
    bottom: "calc(50% - #{77 + offset.y}rem)"
  
  update: (appTime) ->
    return unless @_dragTimeLeft > 0
    @_dragTimeLeft -= appTime.elapsedAppTime
    
    @desktop.audio.pico8Pan PAA.PixelPad.Apps.Drawing.Editor.Desktop.compressPan AEc.getPanForElement @_pico8

  events: ->
    super(arguments...).concat
      'mouseenter .pixelartacademy-pixelpad-apps-drawing-editor-desktop-pico8': @onMouseEnterPico8
      'mouseleave .pixelartacademy-pixelpad-apps-drawing-editor-desktop-pico8': @onMouseLeavePico8
      'click': @onClick
      'mousedown': @onMouseDown
  
  onMouseEnterPico8: (event) ->
    @_handheldDragTiny()
    
  onMouseLeavePico8: (event) ->
    @_handheldDragTiny()
  
  _handheldDragTiny: ->
    # Only play audio when hovering over a deactivated handheld.
    return if @active()
    
    # Don't play immediately after a different drag.
    return if Date.now() - @_lastAudioDragTime < 500
    
    @audio.handheldDragTiny()
    
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
    $(document).on "mouseup.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pico8", (event) =>
      $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pico8'

      @dragging false

      # Close PICO-8 if we haven't moved.
      if not @_moved
        @_draggingDeactivated = true
        @active false

    $(document).on "mousemove.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pico8", (event) =>
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
