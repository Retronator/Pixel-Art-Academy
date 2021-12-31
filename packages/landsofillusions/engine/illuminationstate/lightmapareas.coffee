LOI = LandsOfIllusions

class LOI.Engine.IlluminationState.LightmapAreas
  constructor: (@mesh) ->
    lightmapSize = @mesh.lightmapAreaProperties.lightmapSize()
    @width = lightmapSize.width
    @height = lightmapSize.height

    @areas = []

    for areaProperties in @mesh.lightmapAreaProperties.getAll()
      area = new LOI.Engine.IlluminationState.LightmapArea @mesh, areaProperties
      @areas.push area if area.totalProbeCount

    @activeMipmapLevels = new ComputedField =>
      area.activeMipmapLevel() for area in @areas
    ,
      EJSON.equals

  getNewUpdatePixel: ->
    # Find area with lowest completeness.
    area = _.minBy @areas, (probeMap) => probeMap.completeness()
    area.getNewUpdatePixel()

  debugOutput: ->
    probeMap.debugOutput() for area in @areas
