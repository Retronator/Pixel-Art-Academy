AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Tools.MoveCanvas extends FM.Tool
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Tools.MoveCanvas'
  @displayName: -> "Move canvas"
  
  @initialize()
  
  constructor: ->
    super arguments...

    @moving = new ReactiveField false

    @display = @interface.callAncestorWith 'display'

  onActivated: ->
    # Listen for mouse down.
    $(document).on "mousedown.pixelartacademy-pixelpad-apps-drawing-editor-desktop-tools-move", (event) =>
      $target = $(event.target)

      # Only activate when we're moving from the background or the canvas.
      return unless $target.hasClass('background') or $target.closest('.drawing-area').length

      @moving true

      startingMousePosition =
        x: event.clientX
        y: event.clientY
      
      editor = @interface.getEditorForActiveFile()
      camera = editor.camera()
      originDataField = camera.originData()
      startingOrigin = originDataField.value()

      # Wire end of dragging on mouse up.
      $(document).on "mouseup.pixelartacademy-pixelpad-apps-drawing-editor-desktop-tools-move-dragging", (event) =>
        $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-tools-move-dragging'
        @moving false

      $(document).on "mousemove.pixelartacademy-pixelpad-apps-drawing-editor-desktop-tools-move-dragging", (event) =>
        dragDelta =
          x: event.clientX - startingMousePosition.x
          y: event.clientY - startingMousePosition.y

        scale = camera.effectiveScale()

        originDataField.value
          x: startingOrigin.x - dragDelta.x / scale
          y: startingOrigin.y - dragDelta.y / scale

  onDeactivated: ->
    $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-tools-move'
    $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-tools-move-dragging'
    @moving false
