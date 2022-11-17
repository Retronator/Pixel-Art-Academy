AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Tools.MoveCanvas extends FM.Tool
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Tools.MoveCanvas'
  @displayName: -> "Move canvas"
  
  @initialize()
  
  constructor: ->
    super arguments...

    @moving = new ReactiveField false

    @display = @interface.callAncestorWith 'display'

  onActivated: ->
    # Listen for mouse down.
    $(document).on "mousedown.pixelartacademy-pixelboy-apps-drawing-editor-desktop-tools-move", (event) =>
      $target = $(event.target)

      # Only activate when we're moving from the background or the canvas.
      return unless $target.hasClass('background') or $target.closest('.drawing-area').length

      @moving true

      @_mousePosition =
        x: event.clientX
        y: event.clientY

      # Wire end of dragging on mouse up.
      $(document).on "mouseup.pixelartacademy-pixelboy-apps-drawing-editor-desktop-tools-move-dragging", (event) =>
        $(document).off '.pixelartacademy-pixelboy-apps-drawing-editor-desktop-tools-move-dragging'
        @moving false

      $(document).on "mousemove.pixelartacademy-pixelboy-apps-drawing-editor-desktop-tools-move-dragging", (event) =>
        dragDelta =
          x: event.clientX - @_mousePosition.x
          y: event.clientY - @_mousePosition.y

        editor = @interface.getEditorForActiveFile()
  
        # Note: Read the starting origin directly from the origin computed field (and
        # not origin data) so that the default is applied if the origin data is not set.
        camera = editor.camera()
        origin = camera.origin()
  
        scale = camera.effectiveScale()
  
        camera.originData().value
          x: origin.x - dragDelta.x / scale
          y: origin.y - dragDelta.y / scale

        @_mousePosition =
          x: event.clientX
          y: event.clientY

  onDeactivated: ->
    $(document).off '.pixelartacademy-pixelboy-apps-drawing-editor-desktop-tools-move'
