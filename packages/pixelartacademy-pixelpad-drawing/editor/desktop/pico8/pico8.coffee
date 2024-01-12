AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Pico8 extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Pico8'
  @register @id()
  
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
    
    @device = new ReactiveField null

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
      
    # Create the PICO-8 device once audio context is available, so we can route it through the location mixer.
    @autorun (computation) =>
      return unless audioContext = LOI.adventure.interface.audioManager.context()
      computation.stop()
      
      audioOutputNode = AEc.Node.Mixer.getOutputNodeForName 'location', audioContext
      
      @device new PAA.Pico8.Device.Handheld
        audioContext: audioContext
        audioOutputNode: audioOutputNode
        
        # Relay input/output calls to the cartridge.
        onInputOutput: (address, value) =>
          @cartridge()?.onInputOutput? address, value

        # Enable device interface when the editor is active.
        enabled: => @desktop.active()

    @autorun (computation) =>
      return unless cartridge = @cartridge()
      return unless game = cartridge.game()
      return unless device = @device()

      device.loadGame game, @desktop.activeAsset().project.projectId
    
    # Drag handheld when activating and deactivating.
    Tracker.triggerOnDefinedChange @active, =>
      @audio.handheldDragLong()
      @_lastAudioDragTime = Date.now()
      
      @_dragTimeLeft = 1
    
    # Automatically enter focused mode when active.
    @autorun (computation) =>
      @desktop.focusedMode @active()
    
    # Automatically deactivate when exiting focused mode.
    @autorun (computation) =>
      @active false unless @desktop.focusedMode()
      
  onRendered: ->
    super arguments...
    
    @_pico8 = $('.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pico8')[0]

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
      'pointerenter .pixelartacademy-pixelpad-apps-drawing-editor-desktop-pico8': @onPointerEnterPico8
      'pointerleave .pixelartacademy-pixelpad-apps-drawing-editor-desktop-pico8': @onPointerLeavePico8
      'click': @onClick
      'pointerdown': @onPointerDown
  
  onPointerEnterPico8: (event) ->
    @_handheldDragTiny()
    
  onPointerLeavePico8: (event) ->
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

  onPointerDown: (event) ->
    return unless @active()

    # Only react to clicks directly on the case or screen.
    $target = $(event.target)
    return unless $target.hasClass('pixelartacademy-pico8-device-handheld') or $target.closest('.screen').length

    @dragging true
    @_moved = false

    @_pointerPosition =
      x: event.clientX
      y: event.clientY

    # Wire end of dragging on pointer up anywhere in the window.
    $(document).on "pointerup.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pico8", (event) =>
      $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pico8'

      @dragging false

      # Close PICO-8 if we haven't moved.
      if not @_moved
        @_draggingDeactivated = true
        @active false

    $(document).on "pointermove.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pico8", (event) =>
      @_moved = true
      scale = @display.scale()

      dragDelta =
        x: (event.clientX - @_pointerPosition.x) / scale
        y: (event.clientY - @_pointerPosition.y) / scale

      offset = @positionOffset()
      @positionOffset
        x: offset.x + dragDelta.x
        y: offset.y + dragDelta.y

      @_pointerPosition =
        x: event.clientX
        y: event.clientY
