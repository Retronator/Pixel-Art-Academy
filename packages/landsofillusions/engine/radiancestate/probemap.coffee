LOI = LandsOfIllusions

class LOI.Engine.RadianceState.ProbeMap
  constructor: (@options) ->
    width = @options.size.width
    height = @options.size.height

    # Map which pixels are present in the cluster.
    @pixelMap = new Int32Array width * height

    # Go over all pixel coordinate entries and
    pixelCoordinatesArray = @options.cluster.geometry().pixelCoordinates

    for pixelCoordinatesOffset in [0...pixelCoordinatesArray.length] by 2
      x = pixelCoordinatesArray[pixelCoordinatesOffset]
      y = pixelCoordinatesArray[pixelCoordinatesOffset + 1]

      # See if we've already added this pixel.
      pixelIndex = @_getPixelIndex x, y
      continue if @pixelMap[pixelIndex]

      # Calculate distance from edges.
      horizontalDistance = Math.min x, width - x
      verticalDistance = Math.min y, height - y
      edgeDistance = Math.min horizontalDistance, verticalDistance

      # Start with negative distance so that the innermost pixels will get calculated firts.
      @pixelMap[pixelIndex] = -edgeDistance - 1

    # Find which probe should be calculated first.
    nextPixelIndex = @findLowestPixelIndex()

    dataArray = new Float32Array width * height
    dataArray.fill nextPixelIndex

    @texture = new THREE.DataTexture dataArray, width, height, THREE.AlphaFormat, THREE.FloatType

  findLowestPixelIndex: ->
    minIndex = null
    minValue = Number.POSITIVE_INFINITY

    # Go over all pixels that are not empty.
    for value, index in @pixelMap when value
      if value < minValue
        minValue = value
        minIndex = index

    minIndex

  _getPixelIndex: (x, y) ->
    x + y * @options.size.width

  _getPixelCoordinates: (index) ->
    x = index % @options.size.width
    y = Math.floor index / @options.size.height

    {x, y}
