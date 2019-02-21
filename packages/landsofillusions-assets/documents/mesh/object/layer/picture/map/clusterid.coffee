LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture.Map.ClusterId extends LOI.Assets.Mesh.Object.Layer.Picture.Map
  @type = LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.ClusterId
  @bytesPerPixel = 2

  constructor: (@picture, compressedData) ->
    super arguments...

    @initializeIdData() if compressedData

  resizeToPictureBounds: ->
    super arguments...

    @initializeIdData()

  initializeIdData: ->
    # Create a 16-bit unsigned integer view on top of the data buffer.
    @idData = new Uint16Array @data.buffer

  getPixel: (x, y) ->
    dataIndex = @calculateIdDataIndex x, y
    @idData[dataIndex]

  setPixel: (x, y, value) ->
    dataIndex = @calculateIdDataIndex x, y
    @idData[dataIndex] = value

  calculateIdDataIndex: (x, y) ->
    x + y * @width
