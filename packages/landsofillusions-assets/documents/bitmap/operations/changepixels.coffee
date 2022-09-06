AM = Artificial.Mummification
LOI = LandsOfIllusions

Pako = require 'pako'

compressionOptions =
  level: Pako.Z_BEST_COMPRESSION

class LOI.Assets.Bitmap.Operations.ChangePixels extends AM.Document.Versioning.Operation
  @id: -> 'LandsOfIllusions.Assets.Bitmap.Operations.ChangePixels'
  # layerAddress: array of integers specifying indices of layer groups and the layer
  # bounds: the absolute bounds of the area to change
  #   x, y, width, height
  # compressedPixelsData: binary object with compressed version of pixels, sent to the server

  @initialize()

  execute: (document) ->
    pixelFormat = new LOI.Assets.Bitmap.PixelFormat LOI.Assets.Bitmap.Attribute.OperationMask.id, document.pixelFormat...
    changeArea = new LOI.Assets.Bitmap.Area @bounds.width, @bounds.height, pixelFormat, @compressedPixelsData, true
    layer = document.getLayer @layerAddress

    # Go over each of the changed pixels and overwrite them in the layer.
    changeAreaOperationMaskAttribute = changeArea.attributes[LOI.Assets.Bitmap.Attribute.OperationMask.id]

    for changeAreaY in [0...@bounds.height]
      absoluteY = @bounds.y + changeAreaY
      layerY = absoluteY - layer.bounds.y

      for changeAreaX in [0...@bounds.width]
        absoluteX = @bounds.x + changeAreaX
        layerX = absoluteX - layer.bounds.x

        # See if the pixel was changed at this location.
        continue unless changeAreaOperationMaskAttribute.pixelWasChanged changeAreaX, changeAreaY

        # It was, copy all the attributes from the change area to the layer.
        for attributeId in document.pixelFormat when attributeId isnt LOI.Assets.Bitmap.Attribute.OperationMask.id
          changeAreaAttribute = changeArea.attributes[attributeId]
          layerAttribute = layer.attributes[attributeId]

          changeAreaPixelIndex = changeAreaAttribute.getPixelIndex changeAreaX, changeAreaY
          layerPixelIndex = layerAttribute.getPixelIndex layerX, layerY

          for offset in [0...changeAreaAttribute.constructor.elementsPerPixel]
            newValue = changeAreaAttribute.array[changeAreaPixelIndex + offset]
            layerAttribute.array[layerPixelIndex + offset] = newValue

    # Return that the pixels of the layer were changed.
    layer.getOperationChangedFields compressedPixelsData: true
