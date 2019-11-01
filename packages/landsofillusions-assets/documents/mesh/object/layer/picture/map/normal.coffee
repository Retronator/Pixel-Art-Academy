LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture.Map.Normal extends LOI.Assets.Mesh.Object.Layer.Picture.Map
  @type = LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.Normal
  @bytesPerPixel = 3
  @flagValue = 16

  constructor: (@picture, compressedData) ->
    super arguments...

    @initializeSignedData() if compressedData

  resizeToPictureBounds: ->
    super arguments...

    @initializeSignedData()

  initializeSignedData: ->
    # Create a signed view on top of the data buffer.
    @signedData = new Int8Array @data.buffer

  getPixel: (x, y) ->
    dataIndex = @calculateDataIndex x, y
    x: @signedData[dataIndex] / 127
    y: @signedData[dataIndex + 1] / 127
    z: @signedData[dataIndex + 2] / 127

  setPixel: (x, y, value) ->
    dataIndex = @calculateDataIndex x, y
    @signedData[dataIndex] = Math.round value.x * 127
    @signedData[dataIndex + 1] = Math.round value.y * 127
    @signedData[dataIndex + 2] = Math.round value.z * 127
