AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

Pako = require 'pako'

class LOI.Assets.Bitmap.Operations.ChangePixels extends AM.Document.Versioning.Operation
  @id: -> 'LandsOfIllusions.Assets.Bitmap.Operations.ChangePixels'
  # layerAddress: array of integers specifying indices of layer groups and the layer
  # bounds: the absolute bounds of the area to change
  #   x, y, width, height
  # _pixelsData: binary object with pixel data, not sent to the server
  # compressedPixelsData: binary object with compressed version of pixels, sent to the server
  @combinable = true

  @initialize()
  
  setPixelsData: (pixelsData) ->
    @_pixelsData = pixelsData
  
    # Remove the cached fields.
    @compressedPixelsData = null
    @_hashCode = null
  
  execute: (document) ->
    pixelFormat = new LOI.Assets.Bitmap.PixelFormat LOI.Assets.Bitmap.Attribute.OperationMask.id, document.pixelFormat.attributeIds...
    changeArea = new LOI.Assets.Bitmap.Area @bounds.width, @bounds.height, pixelFormat, @_pixelsData or @compressedPixelsData, not @_pixelsData
    layer = document.getLayer @layerAddress
    
    # Expand the layer if necessary to include these new pixels.
    @_resizeLayerToIncludeBounds layer, @bounds, document.pixelFormat

    # Apply the changed area to the layer.
    @_copyPixels {area: changeArea, bounds: @bounds}, {area: layer, bounds: layer.bounds}, document.pixelFormat

    # Return that the pixels of the layer were changed.
    layer.getOperationChangedFields compressedPixelsData: true
    
  combine: (document, other) ->
    pixelFormat = new LOI.Assets.Bitmap.PixelFormat LOI.Assets.Bitmap.Attribute.OperationMask.id, document.pixelFormat.attributeIds...
  
    changeArea = new LOI.Assets.Bitmap.Area @bounds.width, @bounds.height, pixelFormat, @_pixelsData or @compressedPixelsData, not @_pixelsData
    otherChangeArea = new LOI.Assets.Bitmap.Area other.bounds.width, other.bounds.height, pixelFormat, other._pixelsData or other.compressedPixelsData, not other._pixelsData
    
    resultBounds = @_unionBounds @bounds, other.bounds
    resultArea = new LOI.Assets.Bitmap.Area resultBounds.width, resultBounds.height, pixelFormat
  
    destination = area: resultArea, bounds: resultBounds
  
    @_copyPixels {area: changeArea, bounds: @bounds}, destination, pixelFormat
    @_copyPixels {area: otherChangeArea, bounds: other.bounds}, destination, pixelFormat
    
    @setPixelsData resultArea.pixelsData
    @bounds = resultBounds

    # Return that the operation was combined.
    true
    
  _copyPixels: (source, destination, pixelFormat) ->
    # Go over each of the source pixels and set them in the destination area where the operation mask is set.
    sourceAreaOperationMaskAttribute = source.area.attributes[LOI.Assets.Bitmap.Attribute.OperationMask.id]

    for sourceY in [0...source.bounds.height]
      absoluteY = source.bounds.y + sourceY
      destinationY = absoluteY - destination.bounds.y

      for sourceX in [0...source.bounds.width]
        absoluteX = source.bounds.x + sourceX
        destinationX = absoluteX - destination.bounds.x

        # See if the pixel was changed at this location.
        continue if sourceAreaOperationMaskAttribute and not sourceAreaOperationMaskAttribute.pixelWasChanged sourceX, sourceY

        # It was, copy all the attributes from the source to the destination.
        for attributeId in pixelFormat.attributeIds
          sourceAreaAttribute = source.area.attributes[attributeId]
          destinationAreaAttribute = destination.area.attributes[attributeId]

          sourcePixelIndex = sourceAreaAttribute.getPixelIndex sourceX, sourceY
          destinationPixelIndex = destinationAreaAttribute.getPixelIndex destinationX, destinationY

          for offset in [0...sourceAreaAttribute.constructor.elementsPerPixel]
            newValue = sourceAreaAttribute.array[sourcePixelIndex + offset]
            destinationAreaAttribute.array[destinationPixelIndex + offset] = newValue
          
    # Optimization: Explicit return to not collect results of for loops.
    return

  _resizeLayerToIncludeBounds: (layer, bounds, pixelFormat) ->
    # If the bounds are within the layer bounds, there's nothing to do.
    return if bounds.x >= layer.bounds.x and bounds.y >= layer.bounds.y and bounds.x + bounds.width <= layer.bounds.x + layer.bounds.width and bounds.y + bounds.height <= layer.bounds.y + layer.bounds.height
    
    # Calculate new bounds.
    oldLayerBounds = layer.bounds
    layer.bounds = @_unionBounds oldLayerBounds, bounds
    
    # Transfer old pixels to new layer.
    oldAttributes = layer.attributes
    source =
      area:
        attributes: oldAttributes
      bounds: oldLayerBounds
    
    layer.initialize layer.width, layer.height, pixelFormat
    
    @_copyPixels source, {area: layer, bounds: layer.bounds}, layer.pixelFormat
  
  _unionBounds: (a, b) ->
    rectangleA = new AE.Rectangle a
    rectangleB = new AE.Rectangle b
    
    rectangleA.union(rectangleB).toJSONValue()

  toJSONValue: ->
    @_compressPixelsData()
  
    super arguments...

  clone: ->
    # Note: We want to always compress the data so that further
    # clone and toJSONValue calls will not need compressing.
    @_compressPixelsData()
    
    clone = super arguments...
    clone._pixelsData = @_pixelsData
    clone

  getHashCode: ->
    # Return the cached hash code if we have one. We assume operation will be fully initialized before it will be used.
    return @_hashCode if @_hashCode
    
    # The hash code should be computed from uncompressed data.
    @_decompressPixelsData()
  
    @_hashCode = @constructor.createHashCode
      layerAddress: @layerAddress
      bounds: @bounds
      pixelsData: @_pixelsData
  
    @_hashCode
    
  _compressPixelsData: ->
    @compressedPixelsData ?= Pako.deflateRaw @_pixelsData, LOI.Assets.Bitmap.Area.compressionOptions if @_pixelsData
    
    console.log "Change pixels operation compression ratio: #{(@compressedPixelsData.byteLength / @_pixelsData.byteLength * 100).toFixed(2)}%" if LOI.Assets.debug and @compressedPixelsData and @_pixelsData
    
  _decompressPixelsData: ->
    @_pixelsData ?= Pako.inflateRaw @compressedPixelsData, LOI.Assets.Bitmap.Area.compressionOptions if @compressedPixelsData
