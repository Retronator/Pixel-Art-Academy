AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.HardEraser extends LOI.Assets.SpriteEditor.Tools.HardEraser
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Tools.HardEraser'
  @displayName: -> "Eraser"

  @initialize()

  applyPixels: (spriteData, layerIndex, pixels) ->
    picture = @editor().activePicture()
    picture.clearPixels pixels
