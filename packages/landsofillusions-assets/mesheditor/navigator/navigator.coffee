AE = Artificial.Everywhere
AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Navigator extends LOI.Assets.Editor.Navigator
  @id: -> "LandsOfIllusions.Assets.MeshEditor.Navigator"
  @register @id()

  template: -> @constructor.id()

  meshThumbnail: ->
    return unless meshCanvas = @editor()
    cameraAngleIndex = meshCanvas.cameraAngleIndex()
    return unless meshData = meshCanvas.meshData()
    return unless loader = @interface.getLoaderForActiveFile()

    pictureThumbnails = []

    for object in meshData.objects.getAll()
      for layer in object.layers.getAll()
        picture = layer.getPictureForCameraAngleIndex cameraAngleIndex
        pictureThumbnails.push loader.getPictureThumbnail picture

    new LOI.Assets.MeshEditor.Thumbnail.Pictures pictureThumbnails
