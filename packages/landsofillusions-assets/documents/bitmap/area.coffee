LOI = LandsOfIllusions

Pako = require 'pako'

compressionOptions =
  level: Pako.Z_BEST_COMPRESSION

# An area of a 2D raster image
class LOI.Assets.Bitmap.Area
  # width: width of the area in pixels
  # height: height of the area in pixels
  # pixelFormat: array of attribute Ids, describing the content and order of data in pixelsData
  # pixelsData: ArrayBuffer with all attributes following each other as defined in the document's pixel format
  # attributes: map of attributes with typed arrays isolating the sections of pixels data

  constructor: (@width, @height, @pixelFormat, @pixelsData, compressed) ->
    # There's nothing to do if there are no pixels.
    return unless @width and @height

    pixelsCount = @width * @height
    bytesPerPixel = @pixelFormat.getBytesPerPixel()

    console.log "area start", pixelsCount, bytesPerPixel

    # Decompress pixels data if necessary.
    if @pixelsData and compressed
      console.log "decompressing", @pixelsData, compressionOptions
      @pixelsData = Pako.inflateRaw(@pixelsData, compressionOptions).buffer
      console.log "got", @pixelsData

    # Create pixels data if it was not provided.
    @pixelsData ?= new ArrayBuffer pixelsCount * bytesPerPixel

    # Create typed arrays for each attribute.
    @attributes = {}

    for attributeId in @pixelFormat
      console.log "creating attribute", attributeId
      attributeClass = LOI.Assets.Bitmap.Attribute.getClassForId attributeId
      @attributes[attributeId] = new attributeClass @

  getCompressedPixelsData: ->
    Pako.deflateRaw @pixelsData, compressionOptions

  getPixel: (x, y) ->
    # Make sure the pixel is in bounds.
    return unless 0 <= x < @width and 0 <= y < @height
    
    pixel = {}

    for attributeId in @pixelFormat
      pixel[attributeId] = @attributes[attributeId].getPixel x, y

    pixel
