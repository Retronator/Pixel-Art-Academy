LOI = LandsOfIllusions

class LOI.Engine.IlluminationState.LightmapArea
  constructor: (@mesh, @areaProperties) ->
    @object = @mesh.objects.get @areaProperties.objectIndex
    @layer = @object.layers.get @areaProperties.layerIndex
    @picture = @layer.pictures.get 0
    @pictureBounds = @picture.bounds()

    if @areaProperties.clusterId?
      @cluster = @layer.clusters.get @areaProperties.clusterId
      @bounds = @cluster.boundsInPicture()

    else
      @bounds = _.clone @pictureBounds
      @bounds.x = 0
      @bounds.y = 0

    @width = @bounds.width
    @height = @bounds.height

    @flagsMap = @picture.getMap LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.Flags
    @clusterIdMap = @picture.getMap LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.ClusterId

    @_initializeCoordinateMaps()

    # Iteration counts how many times we've updated the area across all levels.
    @iteration = new ReactiveField 0

    # Write level tells which level we're writing to in the current iteration.
    @writeLevel = new ReactiveField 0

    # Track how far we are in the iteration and level.
    @updatedProbesCountForLevel = new ReactiveField 0
    @updatedProbesCountForIteration = new ReactiveField 0

    @levelProgress = new ComputedField =>
      level = @writeLevel()
      count = @updatedProbesCountForLevel()

      count / @probeCountPerLevel[level]

    # Active level is where the data should be read from.
    @activeLevel = new ComputedField =>
      iteration = @iteration()

      switch iteration
        when 0 then @writeLevel() - 2 + @levelProgress()
        when 1 then @areaProperties.level - 1 + @levelProgress()
        else @areaProperties.level

    # Mip map levels are inverted and start at 0 for the max level.
    @activeMipmapLevel = new ComputedField =>
      @areaProperties.level - @activeLevel()

    @completeness = new ComputedField =>
      iteration = @iteration()
      totalProbesForIteration = if iteration is 0 then @totalProbeCount else @probeCountPerLevel[@areaProperties.level]
      iteration + @updatedProbesCountForIteration() / totalProbesForIteration

    @_nextLevel = 0
    @_nextLevelPixelsCount = 1
    @_nextIndex = 0

    @_updatePixel =
      cluster: null
      pixelCoordinates:
        x: 0
        y: 0
      lightmapCoordinates:
        x: 0
        y: 0
      lightmapMipmapLevel: 0

  _advancePixel: ->
    # Push index forward.
    @_nextIndex++

    # If we're out of bounds, go down a level or start a new iteration.
    if @_nextIndex > @_nextLevelPixelsCount
      @_nextIndex = 0
      @updatedProbesCountForLevel 0

      if @_nextLevel is @areaProperties.level
        @iteration @iteration() + 1
        @updatedProbesCountForIteration 0

      else
        @_nextLevel++
        @_nextLevelPixelsCount = 2 ** (2 * @_nextLevel)
        @writeLevel @_nextLevel

  getNewUpdatePixel: ->
    # Return pixel coordinates and which cluster it's on.
    newPixelIndex = @coordinateMaps[@_nextLevel][@_nextIndex]
    newPixelX = newPixelIndex % @width + @bounds.x
    newPixelY = Math.floor(newPixelIndex / @width) + @bounds.y

    clusterId = @clusterIdMap.getPixel newPixelX, newPixelY

    sizeAtLevel = 2 ** @_nextLevel
    cellX = @_nextIndex % sizeAtLevel
    cellY = Math.floor @_nextIndex / sizeAtLevel
    lightmapMipmapLevel = @areaProperties.level - @_nextLevel
    factorToBottomLevel = 2 ** lightmapMipmapLevel

    @_updatePixel.cluster = @layer.clusters.get clusterId
    @_updatePixel.pixelCoordinates.x = @pictureBounds.x + newPixelX
    @_updatePixel.pixelCoordinates.y = @pictureBounds.y + newPixelY
    @_updatePixel.lightmapCoordinates.x = cellX * factorToBottomLevel + @areaProperties.positionX
    @_updatePixel.lightmapCoordinates.y = cellY * factorToBottomLevel + @areaProperties.positionY
    @_updatePixel.lightmapMipmapLevel = lightmapMipmapLevel

    # Find the next pixel that needs rendering, which also updates the iteration and which layer we're writing to.
    loop
      @_advancePixel()
      break if @coordinateMaps[@_nextLevel][@_nextIndex] >= 0

    @updatedProbesCountForIteration @updatedProbesCountForIteration() + 1
    @updatedProbesCountForLevel @updatedProbesCountForLevel() + 1

    @_updatePixel

  visible: ->
    @layer.visible() and @layer.object.visible()

  debugOutput: ->
    console.log "COORDINATE MAPS FOR LIGHT MAP AREA", @

    for level in [@areaProperties.level..0]
      console.log "Level", level
      size = 2 ** level

      for y in [0...size]
        row = ''

        for x in [0...size]
          value = @coordinateMaps[level][x + y * size]

          row += if value < 0 then ' ' else '#'

        console.log row

  _getPixelIndex: (x, y) ->
    x + y * @width
