LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture.Map.MaterialIndex extends LOI.Assets.Mesh.Object.Layer.Picture.Map
  @type = LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.MaterialIndex
  @bytesPerPixel = 1
  @flagValue = 1

  getPixel: (x, y) ->
    dataIndex = @calculateDataIndex x, y
    @data[dataIndex]

  setPixel: (x, y, value) ->
    dataIndex = @calculateDataIndex x, y
    @data[dataIndex] = value.materialIndex
