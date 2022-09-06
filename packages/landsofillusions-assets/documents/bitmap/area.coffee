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

    # Decompress pixels data if necessary.
    if @pixelsData and compressed
      @pixelsData = Pako.inflateRaw(@pixelsData, compressionOptions).buffer

    # Create pixels data if it was not provided.
    @pixelsData ?= new ArrayBuffer pixelsCount * bytesPerPixel

    # Create typed arrays for each attribute.
    @attributes = {}

    for attributeId in @pixelFormat
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
    
  debugOutput: ->
    console.log "AREA #{@width}x#{@height}"
    
    for attributeId in @pixelFormat
      console.log attributeId
      attribute = @attributes[attributeId]
      elementsPerPixel = attribute.constructor.elementsPerPixel
      
      for y in [0...@height]
        row = ''
        
        for x in [0...@width]
          pixelIndex = attribute.getPixelIndex x, y
          
          for i in [0...elementsPerPixel]
            value = attribute.array[pixelIndex + i]
            
            row += switch
              when value < 0 then '-'
              when value > 9 then '+'
              else value
              
          row += ' ' if elementsPerPixel > 1
        
        console.log row
