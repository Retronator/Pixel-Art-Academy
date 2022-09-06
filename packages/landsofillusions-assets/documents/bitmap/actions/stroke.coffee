AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Actions.Stroke extends AM.Document.Versioning.Action
  constructor: (operatorId, bitmap, layerAddress, changedPixels) ->
    super arguments...

    # Create the forward and backward change pixels operations.
    forwardOperation = new LOI.Assets.Bitmap.Operations.ChangePixels {layerAddress}
    backwardOperation = new LOI.Assets.Bitmap.Operations.ChangePixels {layerAddress}

    # Calculate the bounds of the change.
    firstPixel = changedPixels[0]
    left = firstPixel.x
    right = firstPixel.x
    top = firstPixel.y
    bottom = firstPixel.y

    for pixel in changedPixels
      left = Math.min left, pixel.x
      right = Math.max right, pixel.x
      top = Math.min top, pixel.y
      bottom = Math.max bottom, pixel.y

    bounds =
      x: left
      y: top
      width: right - left + 1
      height: bottom - top + 1

    forwardOperation.bounds = bounds
    backwardOperation.bounds = bounds

    # Prepare the areas for the forward and backward operations.
    pixelFormat = new LOI.Assets.Bitmap.PixelFormat LOI.Assets.Bitmap.Attribute.OperationMask.id, bitmap.pixelFormat...

    forwardArea = new LOI.Assets.Bitmap.Area bounds.width, bounds.height, pixelFormat
    backwardArea = new LOI.Assets.Bitmap.Area bounds.width, bounds.height, pixelFormat

    forwardAreaOperationMask = forwardArea.attributes[LOI.Assets.Bitmap.Attribute.Ids.OperationMask]
    backwardAreaOperationMask = backwardArea.attributes[LOI.Assets.Bitmap.Attribute.Ids.OperationMask]

    forwardAreaFlags = forwardArea.attributes[LOI.Assets.Bitmap.Attribute.Ids.Flags]

    # Determine attribute categories.
    @_colorAttributeClasses ?= [
      LOI.Assets.Bitmap.Attribute.PaletteColor
      LOI.Assets.Bitmap.Attribute.DirectColor
      LOI.Assets.Bitmap.Attribute.MaterialIndex
    ]

    colorAttributeClasses = []
    nonColorAttributeClasses = []

    for attributeId in bitmap.pixelFormat
      attributeClass = LOI.Assets.Bitmap.Attribute.getClassForId attributeId

      if attributeClass in @_colorAttributeClasses
        colorAttributeClasses.push attributeClass

      else if attributeClass isnt LOI.Assets.Bitmap.Attribute.Flags
        nonColorAttributeClasses.push attributeClass

    # Get the current state of the layer.
    layer = bitmap.getLayer layerAddress
    layerFlags = layer.attributes[LOI.Assets.Bitmap.Attribute.Ids.Flags]

    # Go over all the pixels and create the deltas in both directions.
    for pixel in changedPixels
      changeAreaX = pixel.x - left
      changeAreaY = pixel.y - top

      layerX = pixel.x - layer.bounds.x
      layerY = pixel.y - layer.bounds.y

      # Mark that the pixel is changed by this operation.
      forwardAreaOperationMask.pixelWasChanged changeAreaX, changeAreaY, true
      backwardAreaOperationMask.pixelWasChanged changeAreaX, changeAreaY, true

      # Determine which of the color specifiers is used.
      changedColorAttributeClass = null

      for colorAttributeClass in colorAttributeClasses
        if pixel[colorAttributeClass.id]?
          changedColorAttributeClass = colorAttributeClass

      # We only need to provide new values if the color was changed to a new value.
      # Otherwise the pixel was removed and all values should go to zero.
      if changedColorAttributeClass
        # The color was changed to a new value. Switch the color flags to the new attribute.
        existingFlags = layerFlags.getPixel layerX, layerY

        flagPixelIndex = forwardAreaFlags.getPixelIndex changeAreaX, changeAreaY
        forwardAreaFlags.array[flagPixelIndex] = existingFlags

        newColorFlag = colorAttributeClass.flagValue
        otherColorFlags = LOI.Assets.Bitmap.Attribute.allColorFlagsMask & ~newColorFlag

        forwardAreaFlags.setPixelFlagAtIndex flagPixelIndex, newColorFlag
        forwardAreaFlags.clearPixelFlagAtIndex flagPixelIndex, otherColorFlags

        # Set the new color attribute value.
        forwardArea.attributes[changedColorAttributeClass.id].setPixel changeAreaX, changeAreaY, pixel[changedColorAttributeClass.id]

        # Transfer all the other attributes not related to the colors.
        for attributeClass in nonColorAttributeClasses
          value = layer.attributes[attributeClass.id].getPixel layerX, layerY
          forwardArea.attributes[attributeClass.id].setPixel changeAreaX, changeAreaY, value

      # When going backward, we simply write back the old values.
      for attributeId in bitmap.pixelFormat
        oldValue = layer.attributes[attributeId].getPixel layerX, layerY
        backwardArea.attributes[attributeId].setPixel changeAreaX, changeAreaY, oldValue

    # Store compressed pixels data to the operations.
    forwardOperation.compressedPixelsData = forwardArea.getCompressedPixelsData()
    backwardOperation.compressedPixelsData = backwardArea.getCompressedPixelsData()

    # Update operation arrays and the hash code of the action.
    @forward.push forwardOperation
    @backward.push backwardOperation

    @_updateHashCode()
