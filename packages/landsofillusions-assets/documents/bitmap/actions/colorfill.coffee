AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Actions.ColorFill extends AM.Document.Versioning.Action
  constructor: (operatorId, bitmap, layerAddress, newTargetPixel) ->
    super arguments...
    
    # Determine attribute categories.
    colorAttributeClasses = bitmap.pixelFormat.getColorAttributeClasses()

    # Create the forward and backward change pixels operations.
    forwardOperation = new LOI.Assets.Bitmap.Operations.ChangePixels {layerAddress}
    backwardOperation = new LOI.Assets.Bitmap.Operations.ChangePixels {layerAddress}
  
    # Get the current state of the layer.
    layer = bitmap.getLayer layerAddress
    width = layer.bounds.width
    height = layer.bounds.height
    
    layerFlags = layer.attributes[LOI.Assets.Bitmap.Attribute.Ids.Flags]
    getPixelIndex = (x, y) => y * width + x

    # Find current target pixel.
    targetPixelIndex = getPixelIndex newTargetPixel.x, newTargetPixel.y
    
    targetX = newTargetPixel.x - layer.bounds.x
    targetY = newTargetPixel.y - layer.bounds.y
    targetIndex = getPixelIndex targetX, targetY
    
    minX = targetX
    maxX = targetX
    minY = targetY
    maxY = targetY
  
    fringe = [targetIndex]
    visited = new Uint8Array width * height
    
    if layerFlags.pixelExistsAtIndex targetPixelIndex
      # We are filling an area with existing color. Add neighbors if they match the target pixel color attributes.
      tryAdd = (x, y) ->
        return unless 0 <= x < width and 0 <= y < height
      
        pixelIndex = getPixelIndex x, y
        return unless layerFlags.pixelExistsAtIndex pixelIndex
      
        # Found it. Has it been added already?
        return if visited[pixelIndex]
      
        # Is it the same color?
        for attributeClass in colorAttributeClasses
          attributeId = attributeClass.id
          elementsPerPixel = attributeClass.elementsPerPixel
        
          for i in [0...elementsPerPixel]
            testValue = layer.attributes[attributeId].array[pixelIndex * elementsPerPixel + i]
            targetValue = layer.attributes[attributeId].array[targetPixelIndex * elementsPerPixel + i]
            return if testValue isnt targetValue
  
        # It looks good, add it.
        fringe.push pixelIndex
        
    else
      # If the bitmap doesn't have fixed bounds, don't let the fill reach the bounds.
      checkIfBoundsReached = not bitmap.bounds.fixed
      
      # We are filling a transparent area. Add neighbors if they don't exist.
      tryAdd = (x, y) ->
        return unless 0 <= x < width and 0 <= y < height
      
        pixelIndex = getPixelIndex x, y
        return if layerFlags.pixelExistsAtIndex pixelIndex
      
        # It's empty. Has it been added already?
        return if visited[pixelIndex]
  
        # It looks good, add it.
        fringe.push pixelIndex

    while fringe.length
      testPixelIndex = fringe.pop()
      testPixelX = testPixelIndex % width
      testPixelY = Math.floor testPixelIndex / width
      
      if checkIfBoundsReached
        # If we reached one of the bounds, we can't perform the fill since it would leak outside a freeform image.
        return null if testPixelX is 0 or testPixelX is width - 1 or testPixelY is 0 or testPixelY is height - 1

      # Mark the pixel as visited.
      visited[testPixelIndex] = 1
  
      # Update extents.
      minX = Math.min minX, testPixelX
      maxX = Math.max maxX, testPixelX
      minY = Math.min minY, testPixelY
      maxY = Math.max maxY, testPixelY
      
      # Add neighbors.
      tryAdd testPixelX + 1, testPixelY
      tryAdd testPixelX - 1, testPixelY
      tryAdd testPixelX, testPixelY + 1
      tryAdd testPixelX, testPixelY - 1

    changeAreaBounds =
      x: minX
      y: minY
      width: maxX - minX + 1
      height: maxY - minY + 1

    forwardOperation.bounds = changeAreaBounds
    backwardOperation.bounds = changeAreaBounds

    # Prepare the areas for the forward and backward operations.
    pixelFormat = new LOI.Assets.Bitmap.PixelFormat LOI.Assets.Bitmap.Attribute.OperationMask.id, bitmap.pixelFormat.attributeIds...

    forwardArea = new LOI.Assets.Bitmap.Area changeAreaBounds.width, changeAreaBounds.height, pixelFormat
    backwardArea = new LOI.Assets.Bitmap.Area changeAreaBounds.width, changeAreaBounds.height, pixelFormat

    forwardAreaOperationMask = forwardArea.attributes[LOI.Assets.Bitmap.Attribute.Ids.OperationMask]
    backwardAreaOperationMask = backwardArea.attributes[LOI.Assets.Bitmap.Attribute.Ids.OperationMask]

    forwardAreaFlags = forwardArea.attributes[LOI.Assets.Bitmap.Attribute.Ids.Flags]

    # Determine attribute categories.
    colorAttributeClasses = bitmap.pixelFormat.getColorAttributeClasses()
    otherAttributeClasses = bitmap.pixelFormat.getNonColorNonFlagAttributeClasses()
  
    # Determine which of the color specifiers is used.
    changedColorAttributeClass = null
  
    for colorAttributeClass in colorAttributeClasses
      if newTargetPixel[colorAttributeClass.id]?
        changedColorAttributeClass = colorAttributeClass
        
    # Go over all the visited pixels and create the deltas in both directions.
    for layerY in [0...height]
      for layerX in [0...width]
        continue unless visited[getPixelIndex layerX, layerY]
        
        changeAreaX = layerX + layer.bounds.x - changeAreaBounds.x
        changeAreaY = layerY + layer.bounds.y - changeAreaBounds.y
  
        # Mark that the pixel is changed by this operation.
        forwardAreaOperationMask.pixelWasChanged changeAreaX, changeAreaY, true
        backwardAreaOperationMask.pixelWasChanged changeAreaX, changeAreaY, true
  
        # We only need to provide new values if the color was changed to a new value.
        # Otherwise the pixel was removed and all values should go to zero.
        if changedColorAttributeClass
          # The color was changed to a new value. Switch the color flag to the new attribute.
          existingFlags = layerFlags.getPixel layerX, layerY

          flagPixelIndex = forwardAreaFlags.getPixelIndex changeAreaX, changeAreaY
          forwardAreaFlags.array[flagPixelIndex] = existingFlags

          forwardAreaFlags.switchColorFlagAtIndex flagPixelIndex, colorAttributeClass.flagValue
  
          # Set the new color attribute value.
          forwardArea.attributes[changedColorAttributeClass.id].setPixel changeAreaX, changeAreaY, newTargetPixel[changedColorAttributeClass.id]
  
          # Transfer all the other attributes not related to the colors.
          for attributeClass in otherAttributeClasses
            value = layer.attributes[attributeClass.id].getPixel layerX, layerY
            forwardArea.attributes[attributeClass.id].setPixel changeAreaX, changeAreaY, value
  
        # When going backward, we simply write back the old values.
        for attributeId in bitmap.pixelFormat.attributeIds
          oldValue = layer.attributes[attributeId].getPixel layerX, layerY
          backwardArea.attributes[attributeId].setPixel changeAreaX, changeAreaY, oldValue

    # Store compressed pixels data to the operations.
    forwardOperation.setPixelsData forwardArea.pixelsData
    backwardOperation.setPixelsData backwardArea.pixelsData

    # Update operation arrays and the hash code of the action.
    @forward.push forwardOperation
    @backward.push backwardOperation

    @_updateHashCode()
