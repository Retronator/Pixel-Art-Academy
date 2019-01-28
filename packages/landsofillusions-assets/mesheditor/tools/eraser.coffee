AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.Eraser extends LOI.Assets.SpriteEditor.Tools.Eraser
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Tools.Eraser'
  @displayName: -> "Eraser"

  @initialize()

  applyPixels: (spriteData, layerIndex, pixels) ->
    picture = @editor.activePicture()
    picture.clearPixel pixel for pixel in pixels
