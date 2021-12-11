LOI = LandsOfIllusions
OrganicSolver = LOI.Assets.Mesh.Object.Solver.Organic

class OrganicSolver.Cluster
  constructor: (@layerCluster) ->
    @id = @layerCluster.id
    @pictureCluster = @layerCluster.layer.getPictureCluster @id
    @picture = @pictureCluster.picture

    @origin =
      x: @picture.bounds?.x or 0
      y: @picture.bounds?.y or 0

    @pixels = []
    @pixelsMap = {}

    @updatePixels()

  updatePixels: ->
    bounds = @picture.bounds()
    clusterIdMap = @picture.getMap LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.ClusterId

    # Prepare to determine the size of the cluster in picture pixels.
    @minPixel = null
    @maxPixel = null

    for x in [0...bounds.width]
      for y in [0...bounds.height]
        absoluteX = x + bounds.x
        absoluteY = y + bounds.y

        unless @id is clusterIdMap.getPixel x, y
          # Check if this pixel was present before the update.
          if @pixelMap[absoluteX][absoluteY]
            # This pixel was removed from this cluster.
            @removePixelAt absoluteX, absoluteY

          continue

        # Update bounds.
        @minPixel ?= x: absoluteX, y: absoluteY
        @maxPixel ?= x: absoluteX, y: absoluteY

        @minPixel.x = Math.min absoluteX, @minPixel.x
        @minPixel.y = Math.min absoluteY, @minPixel.y
        @maxPixel.x = Math.max absoluteX, @maxPixel.x
        @maxPixel.y = Math.max absoluteY, @maxPixel.y

        # Nothing else to do if we already have this pixel.
        continue if @pixelMap[absoluteX][absoluteY]

        # This is a new pixel added to the cluster.
        @addPixelAt absoluteX, absoluteY

    @boundsInPicture =
      x: @minPixel.x - bounds.x
      y: @minPixel.y - bounds.y
      width: @maxPixel.x - @minPixel.x + 1
      height: @maxPixel.y - @minPixel.y + 1

  addPixelAt: (x, y) ->
    # Create the pixel with neighbors from the pixel map.
    pixel = new OrganicSolver.Pixel x, y, @

    # Add the pixel to this cluster.
    @pixels.push pixel
    @pixelsMap[x] ?= {}
    @pixelsMap[x][y] = pixel

  removePixelAt: (x, y) ->
    pixel = @pixelsMap[x][y]
    pixel.detachFromNeighbors()

    _.pull @pixels, pixel
    @pixelsMap[x][y] = null

  findNeighbors: (clusters) ->
    # Find all the clusters this cluster is next to.
    oldNeighbors = @neighbors
    @neighbors = {}

    # Go over all the pixels in the cluster and see if it has neighbors in any other cluster.
    for pixel in @pixels
      for side, edge of pixel.clusterEdges when edge
        coordinates = pixel.getNeighborCoordinates side

        for cluster in clusters when cluster isnt @
          if otherPixel = cluster.pixelsMap[coordinates.x]?[coordinates.y]
            if @picture is cluster.picture
              # Inside the same picture, it's enough that the pixel is
              # there since it will definitely have a cluster edge with us.
              @neighbors[cluster.id] = cluster

            else
              # Across pictures, we must first make sure this is the edge of island
              # parts (there is no pixel on the other side in the same picture).
              if pixel.isPictureEdgeTowards(otherPixel) and otherPixel.isPictureEdgeTowards(pixel)
                # Now there must also not be any overlap between these two clusters in the vicinity of the pixel.
                overlap = false
                for testX in [pixel.x - 1..pixel.x + 1]
                  for testY in [pixel.y - 1..pixel.y + 1]
                    if @picture.pixelExists(testX, testY) and cluster.picture.pixelExists(textX, testY)
                      overlap = true
                      break

                  break if overlap

                unless overlap
                  # Link the two pixels together.
                  pixel.setNeighbor side, otherPixel
                  oppositeSide = LOI.Assets.Mesh.Object.Solver.Organic.Pixel.sides[side].opposite
                  otherPixel.setNeighbor oppositeSide, pixel

                  # Record neighbor relationship.
                  @neighbors[cluster.id] = cluster

    # Detect adjacency change.
    @adjacencyChanged = false

    for clusterId of @neighbors
      unless oldNeighbors[clusterId]
        @adjacencyChanged = true
        break

    unless @adjacencyChanged
      for clusterId of oldNeighbors
        unless neighbors[clusterId]
          @adjacencyChanged = true
          break

  initializeIsland: (islands) ->
    # Nothing to do if we're already assigned to an island.
    return if @island

    # Create a new island for this cluster. This will flood-fill
    # and assign this island to all its neighbors as well.
    island = new LOI.Assets.Mesh.Object.Solver.Organic.Island @
    islands.push island

  updatePixelNormals: ->
    pixel.updateNormal() for pixel in @pixels
