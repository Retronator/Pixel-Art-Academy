AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Tools.MoveCanvas extends FM.Tool
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Tools.MoveCanvas'
  @displayName: -> "Move canvas"
  
  @initialize()
  
  constructor: ->
    super arguments...

    @moving = new ReactiveField false

    @display = @interface.callAncestorWith 'display'

  onActivated: ->
    # Listen for mouse down.
    $(document).on "mousedown.pixelartacademy-pixelpad-apps-drawing-editor-tools-move", (event) =>
      $target = $(event.target)

      # Only activate when we're moving from the background or the canvas.
      return unless $target.hasClass('background') or $target.closest('.drawing-area').length

      @moving true

      @_mousePosition =
        x: event.clientX
        y: event.clientY

      # Wire end of dragging on mouse up.
      $(document).on "mouseup.pixelartacademy-pixelpad-apps-drawing-editor-tools-move-dragging", (event) =>
        $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-tools-move-dragging'
        @moving false

      $(document).on "mousemove.pixelartacademy-pixelpad-apps-drawing-editor-tools-move-dragging", (event) =>
        dragDelta =
          x: event.clientX - @_mousePosition.x
          y: event.clientY - @_mousePosition.y

        editor = @interface.getEditorForActiveFile()
  
        originDataField = editor.camera().originData()
        origin = originDataField.value()
  
        scale = editor.camera().effectiveScale()

        originDataField.value
          x: origin.x - dragDelta.x / scale
          y: origin.y - dragDelta.y / scale

        @_mousePosition =
          x: event.clientX
          y: event.clientY

  onDeactivated: ->
    $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-tools-move'
