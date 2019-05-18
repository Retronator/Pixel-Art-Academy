AE = Artificial.Everywhere
AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Navigator extends LOI.Assets.Editor.Navigator
  @id: -> "LandsOfIllusions.Assets.MeshEditor.Navigator"
  @register @id()

  getThumbnailSpriteData: ->
    return unless meshCanvas = @editor()
    cameraAngleIndex = meshCanvas.cameraAngleIndex()
    return unless mesh = meshCanvas.meshData()

    # Rebuild layers from objects for active camera angle.
    mesh.getPreviewSprite cameraAngleIndex
