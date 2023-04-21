LOI = LandsOfIllusions

Pako = require 'pako'

# An area of a 2D raster image
class LOI.Assets.Bitmap.Area
  # width: width of the area in pixels
  # height: height of the area in pixels
  # pixelFormat: array of attribute Ids, describing the content and order of data in pixelsData
  # pixelsData: ArrayBuffer with all attributes following each other as defined in the document's pixel format
  # attributes: map of attributes with typed arrays isolating the sections of pixels data
  @compressionOptions =
    level: Pako.Z_BEST_COMPRESSION
  
  constructor: (width, height, pixelFormat, pixelsData, compressed) ->
    @initialize width, height, pixelFormat, pixelsData, compressed

  initialize: (@width, @height, @pixelFormat, @pixelsData, compressed) ->
    @attributes = {}

    # There's nothing to do if there are no pixels.
    return unless @width and @height

    pixelsCount = @width * @height
    bytesPerPixel = @pixelFormat.getBytesPerPixel()

    # Decompress pixels data if necessary.
    if @pixelsData and compressed
      @pixelsData = Pako.inflateRaw(@pixelsData, @constructor.compressionOptions).buffer

    # Create pixels data if it was not provided.
    @pixelsData ?= new ArrayBuffer pixelsCount * bytesPerPixel

    # Create typed arrays for each attribute.
    for attributeId in @pixelFormat.attributeIds
      attributeClass = LOI.Assets.Bitmap.Attribute.getClassForId attributeId
      @attributes[attributeId] = new attributeClass @

  getCompressedPixelsData: ->
    Pako.deflateRaw @pixelsData, @constructor.compressionOptions

  getPixel: (x, y) ->
    # Make sure the pixel is in bounds.
    return unless 0 <= x < @width and 0 <= y < @height

    # If there are no flags, we simply return the values of all attributes.
    return @getPixelValues x, y unless @attributes.flags
    
    # See if the pixel exists.
    return unless flags = @attributes.flags.getPixel x, y
    
    pixel = {}

    for attributeId in @pixelFormat.attributeIds
      # If the attribute has a flag value, make sure the flag is present for this pixel.
      attributeClass = LOI.Assets.Bitmap.Attribute.getClassForId attributeId
      continue if attributeClass.flagValue and not (flags & attributeClass.flagValue)
      
      pixel[attributeId] = @attributes[attributeId].getPixel x, y

    pixel

  getPixelValues: (x, y) ->
    # Make sure the pixel is in bounds.
    return unless 0 <= x < @width and 0 <= y < @height
  
    pixel = {}
  
    for attributeId in @pixelFormat.attributeIds
      pixel[attributeId] = @attributes[attributeId].getPixel x, y
  
    pixel
    
  debugOutput: ->
    console.log "AREA #{@width}x#{@height}"
    
    for attributeId in @pixelFormat.attributeIds
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
