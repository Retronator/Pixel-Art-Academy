LOI = LandsOfIllusions

class LOI.Engine.Textures.LayerProperties extends LOI.Engine.Textures.Properties
  @propertyIndices:
    atlasPositionX: 0
    atlasPositionY: 1
    width: 2
    height: 3

  @maxItems: 256
  @maxProperties: 4

  constructor: ->
    super LOI.Engine.Textures.LayerProperties

  update: (layerProperties) ->
    for layer, layerIndex in layerProperties.getAll()
      for property in ['atlasPositionX', 'atlasPositionY', 'width', 'height']
        @_writeToData layerIndex, @constructor.propertyIndices[property], layer[property]

    @needsUpdate = true
