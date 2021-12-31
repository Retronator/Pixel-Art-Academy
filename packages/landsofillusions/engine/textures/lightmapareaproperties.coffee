LOI = LandsOfIllusions

class LOI.Engine.Textures.LightmapAreaProperties extends LOI.Engine.Textures.Properties
  @propertyIndices:
    positionX: 0
    positionY: 1
    size: 2
    activeMipmapLevel: 3

  @maxItems: 256
  @maxProperties: 4

  constructor: ->
    super LOI.Engine.Textures.LightmapAreaProperties

  update: (lightmapAreaProperties, illuminationState) ->
    activeMipmapLevels = illuminationState.activeMipmapLevels()

    for area, areaIndex in lightmapAreaProperties
      for property in ['positionX', 'positionY', 'size']
        @_writeToData areaIndex, @constructor.propertyIndices[property], area[property]

      @_writeToData areaIndex, @constructor.propertyIndices.activeMipmapLevel, activeMipmapLevels[areaIndex]

    @needsUpdate = true
