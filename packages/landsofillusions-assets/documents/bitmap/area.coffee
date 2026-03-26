AE = Artificial.Everywhere
AM = Artificial.Mirage
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
      
  clone: ->
    pixelFormat = new LOI.Assets.Bitmap.PixelFormat @pixelFormat.attributeIds...
    pixelsData = @pixelsData.slice()
    new LOI.Assets.Bitmap.Area @width, @height, pixelFormat, pixelsData
    
  clear: ->
    array = new Uint8Array @pixelsData
    array.fill 0
  
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

  setPixel: (x, y, values) ->
    # Make sure the pixel is in bounds.
    throw new AE.ArgumentOutOfRangeException "Coordinates are outside of area bounds." unless 0 <= x < @width and 0 <= y < @height

    # If there are no flags, we simply return the values of all attributes.
    unless @attributes.flags
      @setPixelValues x, y, values
      return

    # Clear pixel by default.
    @attributes.flags.setPixel x, y, 0
    return unless values

    for attributeId, value of values
      # If the attribute has a flag value, set the flag for this pixel.
      attributeClass = LOI.Assets.Bitmap.Attribute.getClassForId attributeId

      if attributeClass.flagValue
        @attributes.flags.setPixelFlag x, y, attributeClass.flagValue

      @attributes[attributeId].setPixel x, y, value

  setPixelValues: (x, y, values) ->
    # Make sure the pixel is in bounds.
    throw new AE.ArgumentOutOfRangeException "Coordinates are outside of area bounds." unless 0 <= x < @width and 0 <= y < @height

    for attributeId, value of values
      @attributes[attributeId].setPixel x, y, value

  clearPixel: (x, y) -> @setPixel x, y, null
  
  copyPixels: (sourceArea, sourceBounds, destinationPosition) ->
    return unless sourceArea.attributes
    
    # Go over each of the source pixels and set them in the
    # destination area where the operation mask is set (if provided).
    sourceAreaOperationMaskAttribute = sourceArea.attributes[LOI.Assets.Bitmap.Attribute.OperationMask.id]
    
    for yOffset in [0...sourceBounds.height]
      sourceY = sourceBounds.y + yOffset
      continue unless 0 <= sourceY < sourceArea.height
      
      destinationY = destinationPosition.y + yOffset
      continue unless 0 <= destinationY < @height
      
      for xOffset in [0...sourceBounds.width]
        sourceX = sourceBounds.x + xOffset
        continue unless 0 <= sourceX < sourceArea.width
        
        destinationX = destinationPosition.x + xOffset
        continue unless 0 <= destinationX < @width
        
        # See if the pixel was changed at this location.
        continue if sourceAreaOperationMaskAttribute and not sourceAreaOperationMaskAttribute.pixelWasChanged sourceX, sourceY
        
        # It was, copy all the attributes from the source to the destination.
        for attributeId in @pixelFormat.attributeIds
          continue unless sourceAreaAttribute = sourceArea.attributes[attributeId]
          destinationAreaAttribute = @attributes[attributeId]
          
          sourcePixelIndex = sourceAreaAttribute.getPixelIndex sourceX, sourceY
          destinationPixelIndex = destinationAreaAttribute.getPixelIndex destinationX, destinationY
          
          for offset in [0...sourceAreaAttribute.constructor.elementsPerPixel]
            newValue = sourceAreaAttribute.array[sourcePixelIndex + offset]
            destinationAreaAttribute.array[destinationPixelIndex + offset] = newValue
    
    # Optimization: Explicit return to not collect results of for loops.
    return
    
  importImage: (image, palette) ->
    canvas = new AM.ReadableCanvas image
    imageData = canvas.getFullImageData()
    
    flagsAttribute = @attributes[LOI.Assets.Bitmap.Attribute.Ids.Flags]
    directColorAttribute = @attributes[LOI.Assets.Bitmap.Attribute.Ids.DirectColor]
    paletteColorAttribute = @attributes[LOI.Assets.Bitmap.Attribute.Ids.PaletteColor]
    alphaAttribute = @attributes[LOI.Assets.Bitmap.Attribute.Ids.Alpha]
    
    directColor = r: 0, g: 0, b: 0
    alpha = 0
    
    for x in [0...@width]
      continue unless x < imageData.width

      for y in [0...@height]
        continue unless y < imageData.height
        
        imagePixelIndex = y * imageData.width + x
        imagePixelOffset = imagePixelIndex * 4
        directColor.r = imageData.data[imagePixelOffset] / 255
        directColor.g = imageData.data[imagePixelOffset + 1] / 255
        directColor.b = imageData.data[imagePixelOffset + 2] / 255
        alpha = imageData.data[imagePixelOffset + 3] / 255
        
        if alpha
          if directColorAttribute
            flagsAttribute.setPixelFlag x, y, LOI.Assets.Bitmap.Attribute.DirectColor.flagValue
            directColorAttribute.setPixel x, y, directColor
            
          else if paletteColorAttribute
            flagsAttribute.setPixelFlag x, y, LOI.Assets.Bitmap.Attribute.PaletteColor.flagValue
            paletteColorAttribute.setPixel x, y, palette.closestPaletteColor directColor
            
        if alphaAttribute
          alphaAttribute.setPixel x, y, alpha
  
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
