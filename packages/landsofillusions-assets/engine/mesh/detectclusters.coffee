LOI = LandsOfIllusions

LOI.Assets.Engine.Mesh.detectClusters = (sprite) ->
  console.log "Detecting clusters in sprite", sprite if LOI.Assets.Engine.Mesh.debug

  return unless pixels = sprite.layers?[0].pixels

  clusters = []

  for pixel in pixels
    continue if pixel.cluster?

    # We found a new pixel that is not part of a cluster yet.
    clusterIndex = clusters.length
    cluster = new LOI.Assets.Engine.Mesh.Cluster clusterIndex
    clusters.push cluster

    fringe = [pixel]
    visitedPixels = [pixel]

    while fringe.length
      # Add a fringe pixel to cluster and mark as visited.
      fringePixel = fringe.pop()
      cluster.pixels.push fringePixel
      fringePixel.cluster = cluster

      # Add all neighboring pixels.
      for xOffset in [-1..1]
        for yOffset in [-1..1]
          continue unless xOffset or yOffset

          neighborX = fringePixel.x + xOffset
          neighborY = fringePixel.y + yOffset
          continue unless neighborPixel = _.find pixels, (pixel) -> pixel.x is neighborX and pixel.y is neighborY
          continue if neighborPixel in visitedPixels

          visitedPixels.push neighborPixel

          # Check if this pixel is part of the same cluster.
          if pixel.paletteColor
            continue unless neighborPixel.paletteColor
            continue unless pixel.paletteColor.ramp is neighborPixel.paletteColor.ramp and pixel.paletteColor.shade is neighborPixel.paletteColor.shade
            
          else if pixel.directColor
            continue unless neighborPixel.directColor
            continue unless pixel.directColor.x is neighborPixel.directColor.x and pixel.directColor.y is neighborPixel.directColor.y and pixel.directColor.z is neighborPixel.directColor.z
          
          else if pixel.materialIndex
            continue unless pixel.materialIndex is neighborPixel.materialIndex

          continue unless pixel.normal.x is neighborPixel.normal.x and pixel.normal.y is neighborPixel.normal.y and pixel.normal.z is neighborPixel.normal.z
          
          # This pixel matches the cluster pixel so add it to the fringe.
          fringe.push neighborPixel

    # All cluster pixels were added, process cluster data.
    cluster.process()

  # Compute pixel adjacency.
  for pixel in pixels
    pixel.left = _.find pixels, (testPixel) -> testPixel.x is pixel.x - 1 and testPixel.y is pixel.y
    pixel.right = _.find pixels, (testPixel) -> testPixel.x is pixel.x + 1 and testPixel.y is pixel.y
    pixel.up = _.find pixels, (testPixel) -> testPixel.x is pixel.x and testPixel.y is pixel.y - 1
    pixel.down = _.find pixels, (testPixel) -> testPixel.x is pixel.x and testPixel.y is pixel.y + 1

  console.log "Detected clusters", clusters if LOI.Assets.Engine.Mesh.debug

  clusters
