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
      
    # Create the pencil action.
    picture = @editor().activePicture()
    action = new LOI.Assets.MeshEditor.Helpers.History.Action.Pencil
    action.generateOperations picture, pixels

    # Execute it.
    history = @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.History
    history.addAction action
