FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Translate extends LOI.Assets.SpriteEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Translate'
  @displayName: -> "Translate"

  @initialize()

  onActivated: ->
    # Listen for pointer down.
    $(document).on "pointerdown.landsofillusions-assets-spriteeditor-tools-translate", (event) =>
      $target = $(event.target)

      # Only activate when we're moving on the canvas.
      return unless $target.closest('.landsofillusions-assets-spriteeditor-pixelcanvas').length

      assetData = @editor().assetData()
      paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint
      layerIndex = paintHelper.layerIndex()
      camera = @editor().camera()

      return unless layer = assetData.layers[layerIndex]

      @_pointerPosition =
        x: event.clientX
        y: event.clientY

      # Wire end of dragging on pointer up.
      $(document).on "pointerup.landsofillusions-assets-spriteeditor-tools-translate-pointermove", (event) =>
        $(document).off '.landsofillusions-assets-spriteeditor-tools-translate-pointermove'

      $(document).on "pointermove.landsofillusions-assets-spriteeditor-tools-translate-pointermove", (event) =>
        scale = camera.effectiveScale()

        dragDelta =
          x: Math.round (event.clientX - @_pointerPosition.x) / scale
          y: Math.round (event.clientY - @_pointerPosition.y) / scale

        return unless dragDelta.x or dragDelta.y

        currentSpriteData = @editor().assetData()
        currentLayer = currentSpriteData.layers[layerIndex]
        currentLayerOrigin =
          x: currentLayer.origin?.x or 0
          y: currentLayer.origin?.y or 0

        # Apply delta to the layer origin.
        LOI.Assets.Sprite.updateLayer assetData._id, layerIndex,
          origin:
            x: currentLayerOrigin.x + dragDelta.x
            y: currentLayerOrigin.y + dragDelta.y

        # Also adjust the pointer position by the delta.
        @_pointerPosition.x += dragDelta.x * scale
        @_pointerPosition.y += dragDelta.y * scale

  onDeactivated: ->
    $(document).off '.landsofillusions-assets-spriteeditor-tools-translate'
