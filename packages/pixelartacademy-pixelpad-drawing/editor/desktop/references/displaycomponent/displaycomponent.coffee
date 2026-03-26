AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent extends LOI.Assets.Components.References
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    # Loaded from the PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop namespace.
    subNamespace: true
    variables:
      referencesTrayDragLong: AEc.ValueTypes.Trigger
      referencesTrayDragShort: AEc.ValueTypes.Trigger
      referencesTrayDragTiny:
        valueType: AEc.ValueTypes.Trigger
        throttle: 50

  onCreated: ->
    super arguments...

    @opened = new ReactiveField false
    @hideActive = new ReactiveField false

    # The dragging reference should end up displayed if our tray is closed and hide is not active.
    @autorun (computation) =>
      @draggingDisplayed not @opened() and not @hideActive()

    # Close the tray when clicking outside of it.
    $(document).on 'click.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references', (event) =>
      return if $(event.target).closest('.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references').length

      @opened false

      # Return true so we don't interfere with other click events.
      true
    
    # Drag references tray when opening and closing.
    Tracker.triggerOnDefinedChange @opened, =>
      @audio.referencesTrayDragLong()
      @_lastAudioDragTime = Date.now()
    
    # Drag references tray when about to hide a reference.
    Tracker.triggerOnDefinedChange @hideActive, =>
      @audio.referencesTrayDragShort()
      @_lastAudioDragTime = Date.now()

  onDestroyed: ->
    super arguments...
    
    $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references'

  enabledClass: ->
    'enabled' if @enabled()
    
  openedClass: ->
    'opened' if @opened()

  hideActiveClass: ->
    'hide-active' if @hideActive()
    
  events: ->
    super(arguments...).concat
      'pointerenter .stored-references': @onPointerEnterStoredReferences
      'pointerleave .stored-references': @onPointerLeaveStoredReferences
      'click .stored-references': @onClickStoredReferences
  
  onPointerLeaveStoredReferences: (event) ->
    @_trayDragTiny()
    
  onPointerEnterStoredReferences: (event) ->
    @_trayDragTiny()
    
  _trayDragTiny: ->
    # Only play audio when hovering over closed tray.
    return if @opened() or @hideActive()
    
    # Don't play immediately after a different drag.
    return if Date.now() - @_lastAudioDragTime < 500
    
    @audio.referencesTrayDragTiny()

  onClickStoredReferences: (event) ->
    $target = $(event.target)
    opened = @opened()

    # Don't react to clicks on references to prevent opening on drag end.
    return if $target.closest('.reference').length

    if opened
      # Only react to clicks directly on the stored references.
      return if $target.closest('.actions').length

    @opened not opened
