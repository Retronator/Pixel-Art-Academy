AE = Artificial.Everywhere
AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Navigator extends LOI.Assets.Editor.Navigator
  @id: -> "LandsOfIllusions.Assets.MeshEditor.Navigator"
  @register @id()

  getThumbnailSpriteData: ->
    return unless meshCanvas = @interface.getEditorForActiveFile()
    cameraAngleIndex = meshCanvas.cameraAngleIndex()
    mesh = meshCanvas.meshData()

    # Rebuild layers from objects for active camera angle.
    mesh.getSpriteBoundsAndLayersForCameraAngle cameraAngleIndex

    # The sprite expects materials as a map instead of an array.
    materials = mesh.materials.getAllAsIndexedMap()

    new LOI.Assets.Sprite
      palette: _.pick mesh.palette, ['_id']
      layers: spriteLayers
      materials: materials
      bounds: spriteBounds?.toObject()
