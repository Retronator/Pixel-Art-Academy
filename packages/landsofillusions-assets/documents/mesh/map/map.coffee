AM = Artificial.Mummification
LOI = LandsOfIllusions

Pako = require 'pako'

compressionOptions =
  level: Pako.Z_BEST_COMPRESSION

class LOI.Assets.Mesh.Object.Layer.Picture.Map
  @debug = true

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
      @_origin =
        x: @picture._bounds.x
        y: @picture._bounds.y
      
      throw new AE.ArgumentException "Provided map data does not match picture bounds." unless @data.length is @requiredArrayLength()

    else
      # Create a new buffer for the provided picture.
      @resizeToPictureBounds()

  getCompressedData: ->
    compressedData = Pako.deflateRaw @data, compressionOptions

    if @constructor.debug
      compressionRatio = compressedData.length / @data.length
      console.log "Compressed map #{@constructor.type} from #{@data.length} to #{compressedData.length} (#{Math.round compressionRatio * 100}%)."

    compressedData
    
  requiredArrayLength: ->
    @picture._bounds.width * @picture._bounds.height * @constructor.bytesPerPixel

  resizeToPictureBounds: ->
    newData = new Uint8Array @requiredArrayLength()

    if @data
      oldAbsoluteXStart = @_origin.x
      oldAbsoluteXEnd = @width + @_origin.x - 1

      newAbsoluteXStart = @picture._bounds.x
      newAbsoluteXEnd = @picture._bounds.width + @picture._bounds.x - 1

      # We can only copy the subset of columns that fit into the new bounds.
      absoluteXStart = Math.max oldAbsoluteXStart, newAbsoluteXStart
      absoluteXEnd = Math.min oldAbsoluteXEnd, newAbsoluteXEnd
      copyWidth = absoluteXEnd - absoluteXStart + 1

      sourceXStart = absoluteXStart - @_origin.x
      targetXStart = absoluteXStart - @picture._bounds.x

      bytesPerPixel = @constructor.bytesPerPixel
      copyWidthBytes = copyWidth * bytesPerPixel

      for sourceY in [0...@height]
        absoluteY = sourceY + @_origin.y
        targetY = absoluteY - @picture._bounds.y

        # Is this line even still in bounds?
        continue unless 0 <= targetY < @picture._bounds.height

        sourceIndex = (sourceXStart + sourceY * @width) * bytesPerPixel
        targetIndex = (targetXStart + targetY * @picture._bounds.width) * bytesPerPixel

        for pixelOffset in [0...copyWidthBytes]
          newData[targetIndex] = @data[sourceIndex]
          sourceIndex++
          targetIndex++

    @data = newData
    @width = @picture._bounds.width
    @height = @picture._bounds.height

    @_origin =
      x: @picture._bounds.x
      y: @picture._bounds.y

  getPixel: (x, y) ->
    throw new AE.NotImplementedException "Map must provide how to construct a pixel."

  setPixel: (x, y, value) ->
    throw new AE.NotImplementedException "Map must provide how to set a pixel."

  clearPixel: (x, y) ->
    dataIndex = @calculateDataIndex x, y

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
