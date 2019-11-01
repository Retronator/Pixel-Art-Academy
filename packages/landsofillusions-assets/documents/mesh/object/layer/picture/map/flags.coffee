LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture.Map.Flags extends LOI.Assets.Mesh.Object.Layer.Picture.Map
  @type = LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.Flags
  @bytesPerPixel = 1

  getPixel: (x, y) ->
    dataIndex = @calculateDataIndex x, y
    @data[dataIndex]

  pixelHasFlag: (x, y, flagValue) ->
    dataIndex = @calculateDataIndex x, y
    @data[dataIndex] & flagValue

  setPixelFlag: (x, y, flagValue) ->
    dataIndex = @calculateDataIndex x, y
    @data[dataIndex] |= flagValue

  clearPixelFlag: (x, y, flagValue) ->
    dataIndex = @calculateDataIndex x, y
    @data[dataIndex] &= ~flagValue
  
  pixelExists: (x, y) ->
    @pixelExistsAtIndex @calculateDataIndex x, y

  pixelExistsAtIndex: (dataIndex) ->
    # Pixel exists if at least one flag is set.
    @data[dataIndex] > 0
