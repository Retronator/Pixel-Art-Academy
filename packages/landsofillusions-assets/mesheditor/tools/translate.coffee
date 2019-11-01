FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.Translate extends LOI.Assets.MeshEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Tools.Translate'
  @displayName: -> "Translate"
  @icon: -> "/landsofillusions/assets/spriteeditor/tools/translate.png"

  @initialize()

  onActivated: ->
    # Listen for mouse down.
    $(document).on "mousedown.landsofillusions-assets-mesheditor-tools-translate", (event) =>
      $target = $(event.target)

      # Only activate when we're moving on the canvas.
      return unless $target.closest('.landsofillusions-assets-spriteeditor-pixelcanvas').length
      return unless picture = @editor().activePicture()

      camera = @editor().camera()

      @_mousePosition =
        x: event.clientX
        y: event.clientY

      # Wire end of dragging on mouse up.
      $(document).on "mouseup.landsofillusions-assets-mesheditor-tools-translate-mousemove", (event) =>
        $(document).off '.landsofillusions-assets-mesheditor-tools-translate-mousemove'

      $(document).on "mousemove.landsofillusions-assets-mesheditor-tools-translate-mousemove", (event) =>
        scale = camera.effectiveScale()

        dragDelta =
          x: Math.round (event.clientX - @_mousePosition.x) / scale
          y: Math.round (event.clientY - @_mousePosition.y) / scale

        return unless dragDelta.x or dragDelta.y

        # Apply delta to the picture.
        picture.translate dragDelta.x, dragDelta.y

        # Also adjust the mouse position by the delta.
        @_mousePosition.x += dragDelta.x * scale
        @_mousePosition.y += dragDelta.y * scale

  onDeactivated: ->
    $(document).off '.landsofillusions-assets-mesheditor-tools-translate'
