LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture.Map.DirectColor extends LOI.Assets.Mesh.Object.Layer.Picture.Map
  @type = LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.DirectColor
  @bytesPerPixel = 3
  @flagValue = 4

  getPixel: (x, y) ->
    dataIndex = @calculateDataIndex x, y
    r: @data[dataIndex]
    g: @data[dataIndex + 1]
    b: @data[dataIndex + 2]

  setPixel: (x, y, value) ->
    dataIndex = @calculateDataIndex x, y
    @data[dataIndex] = value.r
    @data[dataIndex + 1] = value.g
    @data[dataIndex + 2] = value.b
