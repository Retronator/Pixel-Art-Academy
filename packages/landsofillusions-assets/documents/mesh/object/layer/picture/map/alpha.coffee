LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture.Map.Alpha extends LOI.Assets.Mesh.Object.Layer.Picture.Map
  @type = LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.Alpha
  @bytesPerPixel = 1
  @flagValue = 8

  getPixel: (x, y) ->
    dataIndex = @calculateDataIndex x, y
    alpha: @data[dataIndex]

  setPixel: (x, y, value) ->
    dataIndex = calculateDataIndex x, y
    @data[dataIndex] = value.alpha
