LOI = LandsOfIllusions

LOI.Engine.IlluminationState.LightmapArea::_initializeCoordinateMaps = ->
  # We need to generate at which pixel coordinates we're supposed to render the probes from, at each resolution level.
  @coordinateMaps = for level in [0..@areaProperties.level]
    size = 2 ** level
    new Int32Array size * size

  bottomLevel = @areaProperties.level
  bottomSize = 2 ** bottomLevel
  @nearestNeighborMap = new Int32Array bottomSize * bottomSize

  @probeCountPerLevel = (0 for level in [0..bottomLevel])

  # Fill the nearest neighbor map and bottom coordinate map with data from the picture.
  for x in [0...bottomSize]
    for y in [0...bottomSize]
      mapIndex = x + y * bottomSize

      # See if we have a pixel for this layer or cluster.
      pictureX = x + @bounds.x
      pictureY = y + @bounds.y
      pixelIsValid = false

      if @picture.pixelExistsRelative pictureX, pictureY
        if @areaProperties.clusterId?
          clusterId = @clusterIdMap.getPixel pictureX, pictureY
          pixelIsValid = clusterId is @areaProperties.clusterId

        else
          pixelIsValid = true

      if pixelIsValid
        # We should be rendering this pixel, so write its index into the map.
        @probeCountPerLevel[bottomLevel]++

        pixelIndex = @_getPixelIndex x, y
        @nearestNeighborMap[mapIndex] = pixelIndex
        @coordinateMaps[bottomLevel][mapIndex] = pixelIndex

      else
        # Mark that we'll have to calculate the nearest neighbor for this pixel.
        @nearestNeighborMap[mapIndex] = -1
        @coordinateMaps[bottomLevel][mapIndex] = -1

  if @probeCountPerLevel[bottomLevel] is 0
    @totalProbeCount = 0
    console.warn "Bad area with no pixels.", @
    return

  # Nothing more to do if we only have one pixel.
  if @areaProperties.level is 0
    @totalProbeCount = 1
    return

  # Determine nearest neighbors, by expanding existing values outwards until all pixels are covered.
  # We write each iteration into a temporary map to ensure only 1 pixel at a time is expanded.
  nearestNeighborMapTemp = @nearestNeighborMap.slice()

  writeNeighbor = (mapIndex, testX, testY) =>
    # Make sure we didn't figure it out already.
    return unless nearestNeighborMapTemp[mapIndex] < 0

    # Make sure we're in bounds.
    return unless 0 <= testX < bottomSize and 0 <= testY < bottomSize

    # See if the test position has a valid value.
    testIndex = testX + testY * bottomSize
    return if @nearestNeighborMap[testIndex] < 0

    # Position is fine, transfer its value.
    nearestNeighborMapTemp[mapIndex] = @nearestNeighborMap[testIndex]

  negativePixelsCount = 1

  while negativePixelsCount > 0
    negativePixelsCount = 0

    for x in [0...bottomSize]
      for y in [0...bottomSize]
        mapIndex = x + y * bottomSize

        if @nearestNeighborMap[mapIndex] < 0
          negativePixelsCount++
          writeNeighbor mapIndex, x - 1, y
          writeNeighbor mapIndex, x + 1, y
          writeNeighbor mapIndex, x, y - 1
          writeNeighbor mapIndex, x, y + 1

        # Also transfer the value to the temporary map in case it was determined during the last round.
        else
          nearestNeighborMapTemp[mapIndex] = @nearestNeighborMap[mapIndex]

    # Make the temporary map the current one.
    [@nearestNeighborMap, nearestNeighborMapTemp] = [nearestNeighborMapTemp, @nearestNeighborMap]

  # Fill higher level coordinate maps with data.
  getIndexAtLowerLevel = (x, y, lowerSize, deltaX, deltaY) ->
    lowerX = x * 2 + deltaX
    lowerY = y * 2 + deltaY
    lowerX + lowerY * lowerSize

  for level in [@areaProperties.level - 1..0]
    size = 2 ** level
    lowerLevel = level + 1
    lowerSize = 2 ** lowerLevel
    factorToBottomMap = 2 ** (bottomLevel - level)

    for x in [0...size]
      for y in [0...size]
        mapIndex = x + y * size

        # See if any of the 4 children has a value.
        topLeft = @coordinateMaps[lowerLevel][getIndexAtLowerLevel(x, y, lowerSize, 0, 0)]
        topRight = @coordinateMaps[lowerLevel][getIndexAtLowerLevel(x, y, lowerSize, 1, 0)]
        bottomLeft = @coordinateMaps[lowerLevel][getIndexAtLowerLevel(x, y, lowerSize, 0, 1)]
        bottomRight = @coordinateMaps[lowerLevel][getIndexAtLowerLevel(x, y, lowerSize, 1, 1)]

        if topLeft < 0 and topRight < 0 and bottomLeft < 0 and bottomRight < 0
          # There are no children so we don't have to render at this position.
          @coordinateMaps[level][mapIndex] = -1

        else
          # This cell covers some of the area, so we should render a probe for it.
          @probeCountPerLevel[level]++

          # Find the nearest neighbor of the pixel closest to the center of this cell.
          bottomX = (x + 0.5) * factorToBottomMap - 1
          bottomY = (y + 0.5) * factorToBottomMap - 1
          bottomIndex = bottomX + bottomY * bottomSize
          @coordinateMaps[level][mapIndex] = @nearestNeighborMap[bottomIndex]

  @totalProbeCount = _.sum @probeCountPerLevel
