LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture.Map.PaletteColor extends LOI.Assets.Mesh.Object.Layer.Picture.Map
  @type = LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.PaletteColor
  @bytesPerPixel = 2
  @flagValue = 2

  getPixel: (x, y) ->
    dataIndex = @calculateDataIndex x, y
    ramp: @data[dataIndex]
    shade: @data[dataIndex + 1]

  setPixel: (x, y, value) ->
    dataIndex = @calculateDataIndex x, y
    @data[dataIndex] = value.ramp
    @data[dataIndex + 1] = value.shade
