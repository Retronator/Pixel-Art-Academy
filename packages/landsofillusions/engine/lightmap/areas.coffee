LOI = LandsOfIllusions

class LOI.Engine.Lightmap.Areas
  constructor: (@mesh) ->
    lightmapSize = @mesh.lightmapAreaProperties.lightmapSize()
    @width = lightmapSize.width
    @height = lightmapSize.height

    @areas = []

    for areaProperties in @mesh.lightmapAreaProperties.getAll()
      area = new LOI.Engine.Lightmap.Area @, areaProperties
      @areas.push area if area.totalProbeCount

    @activeMipmapLevels = new ComputedField =>
      area.activeMipmapLevel() for area in @areas
    ,
      EJSON.equals
    
    initialTextureData = new Uint8Array @width * @height * 4
    @initialTexture = new THREE.DataTexture initialTextureData, @width, @height
    @initialTexture.needsUpdate = true
    
    for area in @areas
      area.setInitialTextureData initialTextureData

  getNewUpdatePixel: ->
    # Find area with lowest completeness.
    area = _.minBy @areas, (probeMap) => probeMap.completeness()
    area.getNewUpdatePixel()

  debugOutput: ->
    probeMap.debugOutput() for area in @areas

  resetActiveLevels: ->
    area.resetActiveLevel() for area in @areas
