LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture extends LOI.Assets.Mesh.Object.Layer.Picture
  setPixels: (pixels, relative) ->
    # Update bounds to accommodate all new pixels.
    boundsUpdated = false
  
    unless @_bounds
      # Create bounds around the first pixel.
      firstPixel = pixels[0]
      
      @_bounds =
        x: firstPixel.x
        y: firstPixel.y
        width: 1
        height: 1
  
      @_calculateBoundsEdges()
      @bounds @_bounds
  
      boundsUpdated = true
      
    pixels = for pixel in pixels
      # Isolate just the properties we're setting.
      properties = _.omit pixel, ['x', 'y']

      # We need to update bounds in absolute coordinates.
      absoluteX = pixel.x
      absoluteY = pixel.y
  
      if relative
        absoluteX += @_bounds.x
        absoluteY += @_bounds.y
  
      if absoluteX < @_bounds.left
        boundsUpdated = true
        @_bounds.left = absoluteX
  
      if absoluteX > @_bounds.right
        boundsUpdated = true
        @_bounds.right = absoluteX
  
      if absoluteY < @_bounds.top
        boundsUpdated = true
        @_bounds.top = absoluteY
  
      if absoluteY > @_bounds.bottom
        boundsUpdated = true
        @_bounds.bottom = absoluteY
  
      {properties, absoluteX, absoluteY}
  
    # Ensure we have the flags and clusters maps before we resize bounds.
    flagsMap = @getMap @constructor.Map.Types.Flags

    if boundsUpdated
      # Calculate new bound parameters and inform others of change.
      @_calculateBoundsParameters()
      @bounds.changedLocally()
      @_resizeMaps()

    # See which pixels are added and removed.
    addList = []
    removeList = []

    # Transfer pixels to maps.
    for pixel in pixels
      # We need to send pixels with relative coordinates.
      pixel.relativeX = pixel.absoluteX - @_bounds.x
      pixel.relativeY = pixel.absoluteY - @_bounds.y

      # See if we're replacing a pixel.
      pixelExists = @maps.flags.pixelExists pixel.relativeX, pixel.relativeY
      pixelChanged = not pixelExists

      for mapType, value of pixel.properties
        if pixelExists or value?
          map = @getMap mapType

        if pixelExists
          if value
            existingValue = map.getPixel pixel.relativeX, pixel.relativeY
            pixelChanged = true unless _.isEqual value, existingValue

          else
            pixelChanged = true unless map.isPixelCleared pixel.relativeX, pixel.relativeY

        if value?
          map.setPixel pixel.relativeX, pixel.relativeY, value
          flagsMap.setPixelFlag pixel.relativeX, pixel.relativeY, map.constructor.flagValue
          
        else
          # We only need to clear the pixel if we have the map.
          continue unless map = @maps[mapType]
          map.clearPixel pixel.relativeX, pixel.relativeY
          flagsMap.clearPixelFlag pixel.relativeX, pixel.relativeY, map.constructor.flagValue

      if pixelChanged
        addList.push pixel
        removeList.push pixel if pixelExists

    # Recompute clusters.
    @_recomputeClusters addList, removeList if addList.length

    @contentUpdated()
