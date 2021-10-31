LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Solver.Organic.Cluster
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
    pixel = new LOI.Assets.Mesh.Object.Solver.Organic.Pixel x, y, @

    # Add the pixel to this cluster.
    @pixels.push pixel
    @pixelsMap[x] ?= {}
    @pixelsMap[x][y] = pixel

  removePixelAt: (x, y) ->
    pixel = @pixelsMap[x][y]
    pixel.detachFromNeighbors()

    _.pull @pixels, pixel
    @pixelsMap[x][y] = null

  findPictureNeighbors: (clusters) ->
    # Find all the clusters this cluster is next to in the same picture.
    @neighbors = {}

    # Go over all the pixels in the cluster and see if it has neighbors in any other cluster.
    for pixel in @pixels
      for side, edge of pixel.clusterEdges when edge
        coordinates = pixel.getNeighborCoordinates side

        for cluster in clusters when cluster isnt @ and @picture is cluster.picture
          if otherPixel = cluster.pixelsMap[coordinates.x]?[coordinates.y]
            # This cluster is a neighbor in the same picture.
            @neighbors[cluster.id] = cluster

            # Link the two pixels together.
            pixel.setNeighbor side, otherPixel
            oppositeSide = LOI.Assets.Mesh.Object.Solver.Organic.Pixel.sides[side].opposite
            otherPixel.setNeighbor oppositeSide, pixel

  initializeIslandPart: (islandParts) ->
    # Nothing to do if we're already assigned to an island part.
    return if @islandPart

    # Create a new island part for this cluster. This will flood-fill
    # and assign this island part to all its neighbors as well.
    islandPart = new LOI.Assets.Mesh.Object.Solver.Organic.IslandPart @
    islandParts.push islandPart
