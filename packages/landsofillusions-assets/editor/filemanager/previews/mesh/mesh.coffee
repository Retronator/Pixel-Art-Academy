AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager.Previews.Mesh extends LOI.Assets.Editor.FileManager.Previews.Sprite
  @id: -> 'LandsOfIllusions.Assets.Editor.FileManager.Previews.Mesh'
  @register @id()

  template: -> 'LandsOfIllusions.Assets.Editor.FileManager.Previews.Sprite'

  _getSpriteData: ->
    mesh = @data()

    # Subscribe to asset and palette.
    LOI.Assets.Asset.forId.subscribe @, LOI.Assets.Mesh.className, mesh._id

    # Get full mesh data.
    mesh = LOI.Assets.Mesh.documents.findOne mesh._id

    # Subscribe to the referenced palette as well.
    if paletteId = mesh.palette?._id
      LOI.Assets.Palette.forId.subscribe paletteId

    # Make sure we have camera angles, otherwise the mesh is either empty or hasn't been fully loaded yet.
    return unless mesh.cameraAngles

    mesh.getPreviewSprite()
