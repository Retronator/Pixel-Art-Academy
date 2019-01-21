FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Translate extends LOI.Assets.SpriteEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Translate'
  @displayName: -> "Translate"

  @initialize()

  onActivated: ->
    # Listen for mouse down.
    $(document).on "mousedown.landsofillusions-assets-spriteeditor-tools-translate", (event) =>
      $target = $(event.target)

      # Only activate when we're moving on the canvas.
      return unless $target.closest('.landsofillusions-assets-spriteeditor-pixelcanvas').length

      spriteData = @editor().spriteData()
      paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint
      layerIndex = paintHelper.layerIndex()
      camera = @editor().camera()

      return unless layer = spriteData.layers[layerIndex]

      @_mousePosition =
        x: event.clientX
        y: event.clientY

      @_layerOrigin =
        x: layer.origin?.x or 0
        y: layer.origin?.y or 0

      # Wire end of dragging on mouse up.
      $(document).on "mouseup.landsofillusions-assets-spriteeditor-tools-translate-mousemove", (event) =>
        $(document).off '.landsofillusions-assets-spriteeditor-tools-translate-mousemove'

      $(document).on "mousemove.landsofillusions-assets-spriteeditor-tools-translate-mousemove", (event) =>
        scale = camera.effectiveScale()

        dragDelta =
          x: Math.round (event.clientX - @_mousePosition.x) / scale
          y: Math.round (event.clientY - @_mousePosition.y) / scale

        return unless dragDelta.x or dragDelta.y

        currentSpriteData = @editor().spriteData()
        currentLayer = currentSpriteData.layers[layerIndex]
        currentLayerOrigin =
          x: currentLayer.origin?.x or 0
          y: currentLayer.origin?.y or 0

        # Apply delta to the layer origin.
        LOI.Assets.Sprite.updateLayer spriteData._id, layerIndex,
          origin:
            x: currentLayerOrigin.x + dragDelta.x
            y: currentLayerOrigin.y + dragDelta.y

        # Also adjust the mouse position by the delta.
        @_mousePosition.x += dragDelta.x * scale
        @_mousePosition.y += dragDelta.y * scale

  onDeactivated: ->
    $(document).off '.landsofillusions-assets-spriteeditor-tools-translate'
