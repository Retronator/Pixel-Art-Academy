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
    pixelFormat = new LOI.Assets.Bitmap.PixelFormat LOI.Assets.Bitmap.Attribute.OperationMask.id, bitmap.pixelFormat.attributeIds...

    forwardArea = new LOI.Assets.Bitmap.Area bounds.width, bounds.height, pixelFormat
    backwardArea = new LOI.Assets.Bitmap.Area bounds.width, bounds.height, pixelFormat

    forwardAreaOperationMask = forwardArea.attributes[LOI.Assets.Bitmap.Attribute.Ids.OperationMask]
    backwardAreaOperationMask = backwardArea.attributes[LOI.Assets.Bitmap.Attribute.Ids.OperationMask]

    forwardAreaFlags = forwardArea.attributes[LOI.Assets.Bitmap.Attribute.Ids.Flags]

    # Determine attribute categories.
    colorAttributeClasses = bitmap.pixelFormat.getColorAttributeClasses()
    otherAttributeClasses = bitmap.pixelFormat.getNonColorNonFlagAttributeClasses()

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
        # The color was changed to a new value. Switch the color flag to the new attribute.
        existingFlags = layerFlags.getPixel layerX, layerY
    
        flagPixelIndex = forwardAreaFlags.getPixelIndex changeAreaX, changeAreaY
        forwardAreaFlags.array[flagPixelIndex] = existingFlags
    
        forwardAreaFlags.switchColorFlagAtIndex flagPixelIndex, changedColorAttributeClass.flagValue

        # Set the new color attribute value.
        forwardArea.attributes[changedColorAttributeClass.id].setPixel changeAreaX, changeAreaY, pixel[changedColorAttributeClass.id]

        # Transfer all the other attributes not related to the colors.
        for attributeClass in otherAttributeClasses
          value = pixel[attributeClass.id] ? layer.attributes[attributeClass.id].getPixel layerX, layerY
          forwardArea.attributes[attributeClass.id].setPixel changeAreaX, changeAreaY, value

      # When going backward, we simply write back the old values.
      for attributeId in bitmap.pixelFormat.attributeIds
        oldValue = layer.attributes[attributeId].getPixel layerX, layerY
        backwardArea.attributes[attributeId].setPixel changeAreaX, changeAreaY, oldValue

    # Store pixels data to the operations.
    forwardOperation.setPixelsData forwardArea.pixelsData
    backwardOperation.setPixelsData backwardArea.pixelsData

    # Update operation arrays and the hash code of the action.
    @forward.push forwardOperation
    @backward.push backwardOperation

    @_updateHashCode()
