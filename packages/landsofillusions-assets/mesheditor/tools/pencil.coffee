AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.Pencil extends LOI.Assets.SpriteEditor.Tools.Pencil
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Tools.Pencil'
  @displayName: -> "Pencil"

  @initialize()
  
  applyPixels: (spriteData, layerIndex, pixels) ->
    # We set the rest of the color properties to null to delete them.
    for pixel in pixels
      pixel.materialIndex ?= null
      pixel.paletteColor ?= null
      pixel.directColor ?= null

    picture = @editor().activePicture()
    picture.setPixels pixels
