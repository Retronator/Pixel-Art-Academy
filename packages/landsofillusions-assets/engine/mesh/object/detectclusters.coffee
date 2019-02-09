LOI = LandsOfIllusions

LOI.Assets.Engine.Mesh.Object.detectClusters = (object) ->
  console.log "Detecting clusters in object", object if LOI.Assets.Engine.Mesh.debug

  return unless layers = object.layers.getAll()

  clusters = []

  for layer, layerIndex in layers
    continue unless picture = layer.pictures.get 0
    continue unless bounds = picture.bounds()
    continue unless flagsMap = picture.maps[LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.Flags]

    width = bounds.width
    height = bounds.height
    assignedPixels = new Uint8Array width * height
    visitedPixels = new Uint8Array width * height

    for x in [0...bounds.width]
      for y in [0...bounds.height]
        unless flagsMap.pixelExists x, y
          assignedPixels[x + y * width] = 1
          continue

        # Skip pixels that have already been assigned to a cluster.
        pixelIndex = x + y * width
        continue if assignedPixels[pixelIndex]

        # We found a new pixel that is not part of a cluster yet.
        clusterIndex = clusters.length
        
        pixelProperties = picture.getMapValuesForPixelRelative x, y
        
        cluster = new LOI.Assets.Engine.Mesh.Object.Cluster clusterIndex, picture, pixelProperties
        clusters.push cluster

        pixel = {x, y}
        fringe = [pixel]
        visitedPixels.fill 0
        visitedPixels[pixelIndex] = 1

        while fringe.length
          # Add a fringe pixel to cluster.
          fringePixel = fringe.pop()

          cluster.pixels.push
            x: fringePixel.x + bounds.x
            y: fringePixel.y + bounds.y
            cluster: cluster

          assignedPixels[fringePixel.x + fringePixel.y * width] = 1

          # Add all neighboring pixels.
          for xOffset in [-1..1]
            neighborX = fringePixel.x + xOffset
            continue unless 0 <= neighborX < width

            for yOffset in [-1..1]
              continue unless xOffset or yOffset

              neighborY = fringePixel.y + yOffset
              continue unless 0 <= neighborY < height

              # Skip if this pixel is already in some cluster.
              neighborIndex = neighborX + neighborY * width
              continue if assignedPixels[neighborIndex]

              # Skip if we've already tried to add this pixel.
              continue if visitedPixels[neighborIndex]
              visitedPixels[neighborIndex] = 1

              # Skip if there's no pixel to add.
              continue unless flagsMap.pixelExists neighborX, neighborY

              # Check if this pixel is part of the same cluster.
              same = true

              for type, map of picture.maps
                unless map.pixelsAreSame x, y, neighborX, neighborY
                  same = false
                  break

              continue unless same

              # This pixel matches the cluster pixel so add it to the fringe.
              fringe.push x: neighborX, y: neighborY

        # All cluster pixels were added, process cluster data.
        cluster.process()

  console.log "Detected clusters", clusters if LOI.Assets.Engine.Mesh.debug

  clusters
