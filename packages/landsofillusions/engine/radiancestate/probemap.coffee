LOI = LandsOfIllusions

class LOI.Engine.RadianceState.ProbeMap
  constructor: (@cluster) ->
    @boundsInPicture = @cluster.boundsInPicture()
    @width = @boundsInPicture.width
    @height = @boundsInPicture.height

    # Map which pixels are present in the cluster.
    @distanceMap = new Int32Array @width * @height

    # Go over all pixels in the cluster picture.
    pictureCluster = @cluster.layer.getPictureCluster @cluster.id
    @clusterIdMap = pictureCluster.picture.getMap LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.ClusterId

    @_resetDistanceMap()

    # Find which probe should be calculated first.
    nextPixelIndex = @_findPixelIndexAtLargestDistance()

    dataArray = new Float32Array @width * @height
    dataArray.fill nextPixelIndex

    @texture = new THREE.DataTexture dataArray, @width, @height, THREE.AlphaFormat, THREE.FloatType

    @_updatedCount = 0

  _resetDistanceMap: ->
    maxBorderDistance = Math.ceil(@width / 2) + Math.ceil(@height / 2) - 2
    @pixelsCount = 0

    for x in [0...@boundsInPicture.width]
      for y in [0...@boundsInPicture.height]
        continue unless @cluster.id is @clusterIdMap.getPixel @boundsInPicture.x + x, @boundsInPicture.y + y
        pixelIndex = @_getPixelIndex x, y

        # Calculate distance from edges.
        horizontalDistance = Math.min x, @width - x - 1
        verticalDistance = Math.min y, @height - y - 1
        edgeDistance = horizontalDistance + verticalDistance

        # Start with negative distance so that the innermost pixels will get calculated first.
        @distanceMap[pixelIndex] = -maxBorderDistance - 1 + edgeDistance

        @pixelsCount++

  _findPixelIndexAtLargestDistance: ->
    maxIndex = null
    maxValue = Number.NEGATIVE_INFINITY

    # Go over all pixels that are not empty.
    for value, index in @distanceMap when value
      if value > maxValue
        maxValue = value
        maxIndex = index

    # If the largest distance is 1, we have no pixel left that hasn't been updated.
    if maxValue is 1
      # Reset the distance map to get a new update cycle.
      @_resetDistanceMap()
      @_initialUpdateDone = true
      return @_findPixelIndexAtLargestDistance()

    maxIndex
    
  getNewUpdatePixel: ->
    # Find the largest pixel index.
    newPixelIndex = @_findPixelIndexAtLargestDistance()
    return unless newPixelIndex?

    newPixelCoordinates = @_getPixelCoordinates newPixelIndex

    @_updatedCount++

    # Return the first pixel coordinates 3 times at the start for faster convergence.
    return newPixelCoordinates if @_updatedCount < 3
    
    # Update proximity to reflect this pixel having the radiance state calculated.
    for x in [0...@width]
      for y in [0...@height]
        pixelIndex = @_getPixelIndex x, y
        
        # See if this is a valid pixel.
        if currentDistance = @distanceMap[pixelIndex]
          # Map to the new pixel if the distance to it is smaller than current representation.
          # Note that negative distances represent initial distance and should always be overwritten.
          distanceFromNewPixel = Math.abs(x - newPixelCoordinates.x) + Math.abs(y - newPixelCoordinates.y)

          if currentDistance < 0 or distanceFromNewPixel < currentDistance
            # Update distance map.
            @distanceMap[pixelIndex] = distanceFromNewPixel + 1

            # Update probe index.
            @texture.image.data[pixelIndex] = newPixelIndex unless @_initialUpdateDone

    @texture.needsUpdate = true

    # Return pixel coordinates.
    newPixelCoordinates

  debugOutput: ->
    for y in [0...@height]
      row = ''

      for x in [0...@width]
        value = Math.abs @distanceMap[@_getPixelIndex(x, y)]

        row += switch
          when value is 0 then '.'
          when value is 1 then ' '
          when value > 9 then '#'
          else value

      console.log row

  _getPixelIndex: (x, y) ->
    x + y * @width

  _getPixelCoordinates: (index) ->
    x = index % @width
    y = Math.floor index / @width

    {x, y}
