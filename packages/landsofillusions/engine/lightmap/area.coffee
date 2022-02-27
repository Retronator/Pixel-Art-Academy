LOI = LandsOfIllusions

class LOI.Engine.Lightmap.Area
  constructor: (@areas, @areaProperties) ->
    @mesh = @areas.mesh
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

    @clusterIdMap = @picture.getMap LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.ClusterId

    @_initializeCoordinateMaps()

    # Iteration counts how many times we've updated the area from the top level down.
    @iteration = new ReactiveField 0
  
    # Write level tells which level we're writing to currently.
    @writeLevel = new ReactiveField 0
  
    # Track how far we are in the iteration and level.
    @updatedProbesCountForIteration = new ReactiveField 0
  
    # Set initial values.
    @resetActiveLevel()
  
    # Determine the maximum write level we will reach in this iteration.
    @maxWriteLevelForIteration = new ComputedField =>
      minUpdateLevelForIteration = @areas.maxUpdateLevel - (LOI.Engine.Lightmap.levelsCount() - 1)
      
      if LOI.Engine.Lightmap.progressiveDeepening()
        minUpdateLevelForIteration += (LOI.Engine.Lightmap.iterationsCount() - 1) - @iteration()

      Math.max 0, @areaProperties.level - minUpdateLevelForIteration
    ,
      true

    @iterationProgress = new ComputedField =>
      level = @maxWriteLevelForIteration()
      count = @updatedProbesCountForIteration()

      count / @probeCountUpToLevel[level]
    ,
      true

    # Active level is where the data should be read from. We only want to get to deeper levels through first iterations.
    @_deepestLevel = 0
    
    @activeLevel = new ComputedField =>
      maxWriteLevelForIteration = @maxWriteLevelForIteration()
  
      @_deepestLevel = Math.max @_deepestLevel, maxWriteLevelForIteration - LOI.Engine.Lightmap.drawLevelDifference() + @iterationProgress()
    ,
      true

    # Mip map levels are inverted and start at 0 for the max level.
    @activeMipmapLevel = new ComputedField =>
      @areaProperties.level - @activeLevel()
    ,
      true

    @completeness = new ComputedField =>
      iterationProgress = @iterationProgress()
      iteration = @iteration()

      (iteration + iterationProgress) / LOI.Engine.Lightmap.iterationsCount()
    ,
      true

    @_nextLevel = 0
    @_nextIndex = 0

    @_updatePixel =
      cluster: null
      pixelCoordinates:
        x: 0
        y: 0
      lightmapCoordinates:
        x: 0
        y: 0
      level: 0
      lightmapMipmapLevel: 0
      iteration: 0
      blendFactor: 0
      
  destroy: ->
    @maxWriteLevelForIteration.stop()
    @iterationProgress.stop()
    @activeLevel.stop()
    @activeMipmapLevel.stop()
    @completeness.stop()

  _advancePixel: ->
    # Push index forward.
    @_nextIndex++

    # If we're at the end of the indices at this level, go down a level or start a new iteration.
    if @_nextIndex is @mapIndexLists[@_nextLevel].length
      @_nextIndex = 0

      if @_nextLevel is @maxWriteLevelForIteration()
        @_nextLevel = 0
        @iteration @iteration() + 1
        @updatedProbesCountForIteration 0

      else
        @_nextLevel++
        
      @writeLevel @_nextLevel

  getNewUpdatePixel: ->
    # Return pixel coordinates and which cluster it's on.
    mapIndex = @mapIndexLists[@_nextLevel][@_nextIndex]
    newPixelIndex = @coordinateMaps[@_nextLevel][mapIndex]
    newPixelX = newPixelIndex % @width + @bounds.x
    newPixelY = Math.floor(newPixelIndex / @width) + @bounds.y

    clusterId = @clusterIdMap.getPixel newPixelX, newPixelY

    sizeAtLevel = 2 ** @_nextLevel
    cellX = mapIndex % sizeAtLevel
    cellY = Math.floor mapIndex / sizeAtLevel
    lightmapMipmapLevel = @areaProperties.level - @_nextLevel
    factorToBottomLevel = 2 ** lightmapMipmapLevel

    @_updatePixel.cluster = @layer.clusters.get clusterId
    @_updatePixel.pixelCoordinates.x = @pictureBounds.x + newPixelX
    @_updatePixel.pixelCoordinates.y = @pictureBounds.y + newPixelY
    @_updatePixel.lightmapCoordinates.x = cellX * factorToBottomLevel + @areaProperties.positionX
    @_updatePixel.lightmapCoordinates.y = cellY * factorToBottomLevel + @areaProperties.positionY
    @_updatePixel.level = @_nextLevel
    @_updatePixel.lightmapMipmapLevel = lightmapMipmapLevel
    iteration = @iteration()
    @_updatePixel.iteration = iteration

    # Calculate blend factor. We want the last level of the iteration to end at 100%.
    differenceToLastLevel = @maxWriteLevelForIteration() - @_nextLevel
    
    if LOI.Engine.Lightmap.progressiveDeepening()
      # With progressive deepening, each previous iteration is an additional step away from completeness.
      differenceToLastLevel += LOI.Engine.Lightmap.iterationsCount() - iteration - 1
    
    @_updatePixel.blendFactor = LOI.Engine.Lightmap.blendingFactorBase() ** differenceToLastLevel
  
    # Count this pixel as updated.
    @updatedProbesCountForIteration @updatedProbesCountForIteration() + 1
  
    # Go to the next pixel that needs rendering, which also updates the iteration and which layer we're writing to.
    @_advancePixel()

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

  resetActiveLevel: ->
    @iteration 0
    @writeLevel 0
    @updatedProbesCountForIteration 0
    @_nextLevel = 0
    @_nextIndex = 0

  setInitialTextureData: (initialTextureData) ->
    size = 2 ** @areaProperties.level

    for y in [0...@height]
      for x in [0...@width]
        value = @coordinateMaps[@areaProperties.level][x + y * size]
        continue if value < 0
        
        textureY = @areaProperties.positionY + y
        textureX = @areaProperties.positionX + x
        textureIndexAlpha = (textureY * @areas.width + textureX) * 4 + 3
        initialTextureData[textureIndexAlpha] = 255

  completnessPercentage: ->
    "#{(@completeness() * 100).toFixed(5)}%"
    
  completenessDebugOutput: (index) ->
    console.log "#{_.padStart index, 5}.",
      "completeness: #{_.padStart @completnessPercentage(), 10}",
      "iteration: #{@iteration()} (#{LOI.Engine.Lightmap.iterationsCount() - 1})",
      "level: #{@_nextLevel} (#{@maxWriteLevelForIteration()})",
      "index: #{@_nextIndex} (#{@mapIndexLists[@_nextLevel].length})",
      "count: #{@updatedProbesCountForIteration()}/#{@probeCountUpToLevel[@maxWriteLevelForIteration()]}"
