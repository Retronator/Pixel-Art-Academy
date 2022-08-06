AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Tools.MoveCanvas extends FM.Tool
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Desktop.Tools.MoveCanvas'
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
      return unless $target.hasClass('background') or $target.closest('.canvas-area').length

      @moving true

      @_mousePosition =
        x: event.clientX
        y: event.clientY

      # Wire end of dragging on mouse up.
      $(document).on "mouseup.pixelartacademy-pixelboy-apps-drawing-editor-desktop-tools-move-dragging", (event) =>
        $(document).off '.pixelartacademy-pixelboy-apps-drawing-editor-desktop-tools-move-dragging'
        @moving false

      $(document).on "mousemove.pixelartacademy-pixelboy-apps-drawing-editor-desktop-tools-move-dragging", (event) =>
        scale = @display.scale()

        dragDelta =
          x: (event.clientX - @_mousePosition.x) / scale
          y: (event.clientY - @_mousePosition.y) / scale

        editor = @interface.getEditorForActiveFile()
        offset = editor.desktop.canvasPositionOffset()
        editor.desktop.canvasPositionOffset
          x: offset.x + dragDelta.x
          y: offset.y + dragDelta.y

        @_mousePosition =
          x: event.clientX
          y: event.clientY

  onDeactivated: ->
    $(document).off '.pixelartacademy-pixelboy-apps-drawing-editor-desktop-tools-move'
