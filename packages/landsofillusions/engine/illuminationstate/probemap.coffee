'use strict'

LOI = LandsOfIllusions

class LOI.Engine.IlluminationState.ProbeMap
  constructor: (@atlas, @layer) ->
    @picture = @layer.pictures.get 0
    @bounds = @picture.bounds()
    @width = @bounds.width
    @height = @bounds.height

    @layerProperties = @atlas.mesh.layerProperties.getPropertiesForLayer @layer
    @positionInAtlas =
      x: @layerProperties.atlasPositionX
      y: @layerProperties.atlasPositionY

    @flagsMap = @picture.getMap LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.Flags
    @clusterIdMap = @picture.getMap LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.ClusterId

    @iteration = 0
    @distanceMap = new Int32Array @width * @height
    @_resetDistanceMap()

    # Find which probe should be calculated first.
    nextPixelIndex = @_findPixelIndexAtLargestDistance()

    # Write initial value to this layer's part of the atlas.
    for x in [0...@width]
      for y in [0...@height]
        @atlas.writeToPixel @positionInAtlas.x + x, @positionInAtlas.y + y, nextPixelIndex

    @_updatePixel =
      cluster: null
      pixelCoordinates:
        x: 0
        y: 0
      atlasCoordinates:
        x: 0
        y: 0

  _resetDistanceMap: ->
    maxBorderDistance = Math.ceil(@width / 2) + Math.ceil(@height / 2) - 2
    @pixelsCount = 0
    @updatedPixelsCount = 0

    for x in [0...@width]
      for y in [0...@height]
        continue unless @flagsMap.pixelExists x, y
        pixelIndex = @_getPixelIndex x, y

        # Calculate distance from edges.
        horizontalDistance = Math.min x, @width - x - 1
        verticalDistance = Math.min y, @height - y - 1
        edgeDistance = horizontalDistance + verticalDistance

        # Start with negative distance so that the innermost pixels will get calculated first.
        @distanceMap[pixelIndex] = -maxBorderDistance - 1 + edgeDistance

        @pixelsCount++

    @iteration++

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
    # First iteration only renders the central pixel, so skip to new iteration after it was rendered.
    if @iteration < 2 and @updatedPixelsCount > 0
      @_resetDistanceMap()

    # Find the largest pixel index.
    newPixelIndex = @_findPixelIndexAtLargestDistance()
    return unless newPixelIndex?

    newPixelX = newPixelIndex % @width
    newPixelY = Math.floor newPixelIndex / @width
    
    # Update proximity to reflect this pixel having the radiance state calculated.
    for x in [0...@width]
      for y in [0...@height]
        pixelIndex = @_getPixelIndex x, y
        
        # See if this is a valid pixel.
        if currentDistance = @distanceMap[pixelIndex]
          # Map to the new pixel if the distance to it is smaller than current representation.
          # Note that negative distances represent initial distance and should always be overwritten.
          distanceFromNewPixel = Math.abs(x - newPixelX) + Math.abs(y - newPixelY)

          if currentDistance < 0 or distanceFromNewPixel < currentDistance
            # Update distance map.
            @distanceMap[pixelIndex] = distanceFromNewPixel + 1

            # Update probe index.
            @atlas.writeToPixel @positionInAtlas.x + x, @positionInAtlas.y + y, newPixelIndex unless @_initialUpdateDone

    # Return pixel coordinates and which cluster it's on.
    clusterId = @clusterIdMap.getPixel newPixelX, newPixelY

    @_updatePixel.cluster = @layer.clusters.get clusterId
    @_updatePixel.pixelCoordinates.x = @bounds.x + newPixelX
    @_updatePixel.pixelCoordinates.y = @bounds.y + newPixelY
    @_updatePixel.atlasCoordinates.x = @positionInAtlas.x + newPixelX
    @_updatePixel.atlasCoordinates.y = @positionInAtlas.y + newPixelY

    @updatedPixelsCount++

    @_updatePixel

  visible: ->
    @layer.visible() and @layer.object.visible()

  completeness: ->
    @iteration + @updatedPixelsCount / @pixelsCount

  debugOutput: ->
    console.log "DISTANCE MAP FOR PROBE MAP", @

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
