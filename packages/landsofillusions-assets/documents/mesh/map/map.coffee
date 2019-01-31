AM = Artificial.Mummification
LOI = LandsOfIllusions

Pako = require 'pako'

compressionOptions = strategy: Pako.Z_RLE

class LOI.Assets.Mesh.Object.Layer.Picture.Map
  @Types:
    Flags: "flags"
    MaterialIndex: "materialIndex"
    PaletteColor: "paletteColor"
    DirectColor: "directColor"
    Alpha: "alpha"
    Normal: "normal"

  # Override to provide information for the specific map type.
  @type = null
  @bytesPerPixel = null
  @flagValue = 0
  @flagMaskValue = null

  constructor: (@picture, compressedData) ->
    if compressedData
      # Decompress data directly. We assume it is already sized correctly.
      @data = Pako.inflateRaw compressedData
      @width = @picture._bounds.width
      @height = @picture._bounds.height
      
      throw new AE.ArgumentException "Provided map data does not match picture bounds." unless @data.length is @requiredArrayLength()

    else
      # Create a new buffer for the provided picture.
      @resizeToPictureBounds()

  getCompressedData: ->
    Pako.deflateRaw @data, compressionOptions
    
  requiredArrayLength: ->
    @picture._bounds.width * @picture._bounds.height * @constructor.bytesPerPixel

  resizeToPictureBounds: ->
    newData = new Uint8Array @requiredArrayLength()

    if @data
      # TODO: Transfer data to new buffer.
      newData[0] = 0

    @data = newData
    @width = @picture._bounds.width
    @height = @picture._bounds.height

  getPixel: (x, y) ->
    throw new AE.NotImplementedException "Map must provide how to construct a pixel."

  setPixel: (x, y, value) ->
    throw new AE.NotImplementedException "Map must provide how to set a pixel."

  clearPixel: (x, y) ->
    dataIndex = calculateDataIndex x, y

    for offset in [0...@constructor.bytesPerPixel]
      @data[dataIndex + offset] = 0

  calculateDataIndex: (x, y) ->
    (x + y * @width) * @constructor.bytesPerPixel

  pixelsAreSame: (x1, y1, x2, y2) ->
    dataIndex1 = calculateDataIndex x1, y1
    dataIndex2 = calculateDataIndex x2, y2

    @pixelsAreSameAtIndices dataIndex1, dataIndex2

  pixelsAreSameAtIndices: (dataIndex1, dataIndex2) ->
    for offset in [0...@constructor.bytesPerPixel]
      return false unless @data[dataIndex1 + offset] is @data[dataIndex2 + offset]
      
    true
