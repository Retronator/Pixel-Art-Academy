AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Desktop.References extends LOI.Assets.Components.References
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Desktop.References'
  @register @id()

  onCreated: ->
    super arguments...

    @opened = new ReactiveField false
    @hideActive = new ReactiveField false

    # The dragging reference should end up displayed if our tray is closed and hide is not active.
    @autorun (computation) =>
      @draggingDisplayed not @opened() and not @hideActive()

    # Close the tray when clicking outside of it.
    $(document).on 'click.pixelartacademy-pixelboy-apps-drawing-editor-desktop-references', (event) =>
      return if $(event.target).closest('.pixelartacademy-pixelboy-apps-drawing-editor-desktop-references').length

      @opened false

      # Return true so we don't interfere with other click events.
      true

  onDestroyed: ->
    $(document).off '.pixelartacademy-pixelboy-apps-drawing-editor-desktop-references'

  openedClass: ->
    'opened' if @opened()

  hideActiveClass: ->
    'hide-active' if @hideActive()
    
  events: ->
    super(arguments...).concat
      'click .stored-references': @onClickStoredReferences

  onClickStoredReferences: (event) ->
    $target = $(event.target)
    opened = @opened()

    # Don't react to clicks on references to prevent opening on drag end.
    return if $target.closest('.reference').length

    if opened
      # Only react to clicks directly on the stored references.
      return if $target.closest('.actions').length

    @opened not opened
