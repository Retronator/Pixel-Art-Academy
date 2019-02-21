LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture extends LOI.Assets.Mesh.Object.Layer.Picture
  clearPixels: (pixels, relative) ->
    return unless @_bounds

    # See which pixels are actually removed.
    removeList = []

    for pixel in pixels
      # We need to analyze pixels with relative coordinates.
      pixel.relativeX = pixel.x
      pixel.relativeY = pixel.y

      unless relative
        pixel.relativeX -= @_bounds.x
        pixel.relativeY -= @_bounds.y

      # Make sure not to index outside of bounds.
      continue unless 0 <= pixel.relativeX < @_bounds.width and 0 <= pixel.relativeY < @_bounds.height

      # Make sure the pixel exists.
      continue unless @maps.flags.pixelExists pixel.relativeX, pixel.relativeY

      pixel.absoluteX = pixel.x
      pixel.absoluteY = pixel.y

      if relative
        pixel.absoluteX += @_bounds.x
        pixel.absoluteY += @_bounds.y

      removeList.push pixel

    # Clear pixels from maps. We do this in relative coordinates.
    for type, map of @maps
      # Cluster map is not cleared here, but will be later when clusters are recomputed.
      continue if type is @constructor.Map.Types.ClusterId

      for pixel in removeList
        map.clearPixel pixel.relativeX, pixel.relativeY

    # Recompute clusters before we change the bounds.
    @_recomputeClusters [], removeList if removeList.length

    # Update bounds to account for removed pixels. We do this in absolute coordinates.
    recomputeBounds = false

    for pixel in removeList
      # Only if the pixel is on the edge we need to recompute bounds.
      if pixel.absoluteX is @_bounds.left or pixel.absoluteX is @_bounds.right or pixel.absoluteY is @_bounds.top or pixel.absoluteY is @_bounds.bottom
        recomputeBounds = true
        break

    if recomputeBounds
      # Analyze the flags map to see which pixels remain present.
      newBounds = @maps.flags.computeBounds()
      boundsHaveChanged = false

      if newBounds? is @_bounds?
        for key, value of newBounds
          unless @_bounds[key] is value
            boundsHaveChanged = true
            break

      else
        boundsHaveChanged = true

      if boundsHaveChanged
        @_bounds = newBounds

        if @_bounds
          @_calculateBoundsEdges()
          @bounds @_bounds
          @_resizeMaps()

        else
          # Delete all maps.
          @_removeMaps()

    @contentUpdated()
