LOI = LandsOfIllusions

class LOI.Engine.Textures.MaterialProperties extends THREE.DataTexture
  @propertyIndices:
    ramp: 0
    shade: 1
    dither: 2
    reflectionIntensity: 3
    reflectionShininess: 4
    reflectionSmoothFactor: 5
    translucencyAmount: 6
    translucencyDither: 7
    translucencyTint: 8
    shadowDither: 9
    shadowTint: 10

  @maxMaterials: 256
  @maxProperties: 8

  constructor: (mesh) ->
    MaterialProperties = LOI.Engine.Textures.MaterialProperties
    textureData = new Float32Array MaterialProperties.maxMaterials * MaterialProperties.maxProperties
    super textureData, MaterialProperties.maxMaterials, MaterialProperties.maxProperties, THREE.AlphaFormat, THREE.FloatType

    Tracker.nonreactive => @update mesh if mesh

  update: (mesh) ->
    materials = mesh.materials.getAll()

    for materialPropertiesEntry, materialIndex in mesh.materialProperties.getAll()
      if materialPropertiesEntry.paletteColor
        @_writeToData materialIndex, @constructor.propertyIndices.ramp, materialPropertiesEntry.paletteColor.ramp
        @_writeToData materialIndex, @constructor.propertyIndices.shade, materialPropertiesEntry.paletteColor.shade

      else if materialPropertiesEntry.materialIndex
        material = materials[materialPropertiesEntry.materialIndex]
        @_writeToData materialIndex, @constructor.propertyIndices.ramp, material.ramp
        @_writeToData materialIndex, @constructor.propertyIndices.shade, material.shade
        @_writeToData materialIndex, @constructor.propertyIndices.dither, material.dither
        @_writeToData materialIndex, @constructor.propertyIndices.reflectionIntensity, material.reflection?.intensity
        @_writeToData materialIndex, @constructor.propertyIndices.reflectionShininess, material.reflection?.shininess or 1
        @_writeToData materialIndex, @constructor.propertyIndices.reflectionSmoothFactor, material.reflection?.smoothFactor
        @_writeToData materialIndex, @constructor.propertyIndices.translucencyAmount, material.translucency?.amount or 0
        @_writeToData materialIndex, @constructor.propertyIndices.translucencyDither, material.translucency?.shadow?.dither ? material.translucency?.dither or 0
        @_writeToData materialIndex, @constructor.propertyIndices.translucencyTint, material.translucency?.shadow?.tint or false
        @_writeToData materialIndex, @constructor.propertyIndices.shadowDither, material.shadow?.dither
        @_writeToData materialIndex, @constructor.propertyIndices.shadowTint, material.shadow?.tint or false

    @needsUpdate = true

  _writeToData: (materialIndex, propertyIndex, value) ->
    if _.isBoolean value
      # Convert boolean to float.
      value = if value then 1 else 0

    dataIndex = materialIndex + propertyIndex * @constructor.maxMaterials
    @image.data[dataIndex] = value ? 0
