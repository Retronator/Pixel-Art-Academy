AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.Pencil extends LOI.Assets.SpriteEditor.Tools.Pencil
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Tools.Pencil'
  @displayName: -> "Pencil"

  @initialize()
  
  applyPixels: (spriteData, layerIndex, pixels) ->
    picture = @editor.activePicture()
    picture.setPixel pixel for pixel in pixels
