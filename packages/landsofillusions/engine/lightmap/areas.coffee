LOI = LandsOfIllusions

class LOI.Engine.Lightmap.Areas
  constructor: (@mesh) ->
    lightmapSize = @mesh.lightmapAreaProperties.lightmapSize()
    @width = lightmapSize.width
    @height = lightmapSize.height
  
    lightmapAreaProperties = @mesh.lightmapAreaProperties.getAll()
    
    @maxAreaLevel = _.maxBy(lightmapAreaProperties, (areaProperties) => areaProperties.level).level
    @maxUpdateLevel = @maxAreaLevel
  
    @areas = []
  
    for areaProperties in lightmapAreaProperties
      area = new LOI.Engine.Lightmap.Area @, areaProperties
      @areas.push area if area.totalProbeCount

    @activeMipmapLevels = new ComputedField =>
      area.activeMipmapLevel() for area in @areas
    ,
      EJSON.equals
    ,
      true
    
    initialTextureData = new Uint8Array @width * @height * 4
    @initialTexture = new THREE.DataTexture initialTextureData, @width, @height
    @initialTexture.needsUpdate = true
    
    for area in @areas
      area.setInitialTextureData initialTextureData
      
  destroy: ->
    @activeMipmapLevels.stop()
    area.destroy() for area in @areas

  getNewUpdatePixel: ->
    # Find area with lowest completeness.
    leastCompleteArea = _.minBy @areas, (area) => area.completeness()

    if LOI.Engine.Lightmap.debug
      if leastCompleteArea.completeness() < 1
        console.log "Updating lightmap area", leastCompleteArea, "with completeness", leastCompleteArea.completnessPercentage()
        console.log "Full completeness report:"
        area.completenessDebugOutput index for area, index in @areas
        
    # Nothing to do if all areas completed their update.
    return if leastCompleteArea.completeness() >= 1
  
    leastCompleteArea.getNewUpdatePixel()

  debugOutput: ->
    probeMap.debugOutput() for area in @areas

  resetActiveLevels: ->
    area.resetActiveLevel() for area in @areas

  completeness: ->
    _.sumBy(@areas, (area) => area.completeness()) / @areas.length
