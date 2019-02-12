LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture extends LOI.Assets.Mesh.Object.Layer.Picture
  _detectClusters: ->
    console.log "Detecting clusters in picture", @ if @constructor.debug

    return unless bounds = @bounds()
    return unless flagsMap = @maps[@constructor.Map.Types.Flags]

    width = bounds.width
    height = bounds.height
    arraysLength = width * height

    if @_detectedClusters?.length is arraysLength
      @_detectedClusters.fill 0

    else
      @_detectedClusters = new Uint16Array arraysLength

    @_visitedPixels = new Uint8Array arraysLength unless @_visitedPixels?.length is arraysLength

    clusterIndex = 0
    clusters = {}

    # TODO: Add support for solver specifying what maps should be compared to determine same clusters.
    compareMaps = _.pick @maps, ['materialIndex', 'directColor', 'paletteColor', 'alpha', 'normal']

    for x in [0...width]
      for y in [0...height]
        # Skip pixels that are not in the recompute mask.
        pixelIndex = x + y * width
        continue unless @_clusterRecomputeMask[pixelIndex]
        
        # Skip pixels that do not exist.
        continue unless flagsMap.pixelExists x, y

        # Skip pixels that have already been assigned to a cluster.
        continue if @_detectedClusters[pixelIndex]

        # We found a new pixel that is not part of a cluster yet. Assign it a new index.
        clusterIndex++
        clusters[clusterIndex] = @getMapValuesForPixelRelative x, y

        # Add the starting pixel to a new fringe.
        fringe = [{x, y}]
        
        # Reset visited pixels to the new fringe.
        @_visitedPixels.fill 0
        @_visitedPixels[pixelIndex] = 1

        while fringe.length
          # Add a fringe pixel to cluster.
          fringePixel = fringe.pop()
          @_detectedClusters[fringePixel.x + fringePixel.y * width] = clusterIndex

          # Add all neighboring pixels.
          for xOffset in [-1..1]
            neighborX = fringePixel.x + xOffset
            continue unless 0 <= neighborX < width

            for yOffset in [-1..1]
              continue unless xOffset or yOffset

              neighborY = fringePixel.y + yOffset
              continue unless 0 <= neighborY < height
              
              # Skip if this pixel is not in the recompute mask.
              neighborIndex = neighborX + neighborY * width
              continue unless @_clusterRecomputeMask[neighborIndex]

              # Skip if this pixel is already in some cluster.
              continue if @_detectedClusters[neighborIndex]

              # Skip if we've already tried to add this pixel.
              continue if @_visitedPixels[neighborIndex]
              @_visitedPixels[neighborIndex] = 1

              # Skip if there's no pixel to add.
              continue unless flagsMap.pixelExists neighborX, neighborY

              # Check if this pixel is part of the same cluster.
              same = true

              for type, map of compareMaps
                unless map.pixelsAreSame x, y, neighborX, neighborY
                  same = false
                  break

              continue unless same

              # This pixel matches the cluster pixel so add it to the fringe.
              fringe.push x: neighborX, y: neighborY

    console.log "Detected clusters", clusters, @_detectedClusters if @constructor.debug

    clusters
