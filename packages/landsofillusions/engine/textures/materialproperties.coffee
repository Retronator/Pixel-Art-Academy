LOI = LandsOfIllusions

class LOI.Engine.Textures.MaterialProperties extends LOI.Engine.Textures.Properties
  @propertyIndices:
    paletteColor: 0 # ramp, shade
    dither: 1
    reflectionProperties: 2 # intensity, shininess, smooth factor
    translucency: 3 # amount, dither, tint
    translucencyShadow: 4 # dither, ting
    reflectance: 5 # r, g, b
    emission: 6 # r, g, b
    refractiveIndex: 7 # r, g, b
    structure: 8 # surface roughness, subsurface heterogeneity, conductivity

  @maxItems: 256
  @maxProperties: 16

  constructor: ->
    super LOI.Engine.Textures.MaterialProperties

  update: (materialProperties) ->
    materials = materialProperties.mesh.materials.getAll()

    for materialPropertiesEntry, materialIndex in materialProperties.getAll()
      if materialPropertiesEntry.paletteColor
        material = _.clone materialPropertiesEntry.paletteColor

      else if materialPropertiesEntry.materialIndex?
        material = materials[materialPropertiesEntry.materialIndex]

      @_writeToData materialIndex, @constructor.propertyIndices.paletteColor, material.ramp, material.shade
      @_writeToData materialIndex, @constructor.propertyIndices.dither, material.dither
      @_writeToData materialIndex, @constructor.propertyIndices.reflectionProperties, material.reflection?.intensity ? 0, material.reflection?.shininess ? 1, material.reflection?.smoothFactor ? 0
      @_writeToData materialIndex, @constructor.propertyIndices.translucency, material.translucency?.amount ? 0, material.translucency?.dither ? 0, material.translucency?.tint ? false
      @_writeToData materialIndex, @constructor.propertyIndices.translucencyShadow, material.translucency?.shadow?.dither ? material.translucency?.dither ? 0, material.translucency?.shadow?.tint ? false
      @_writeToData materialIndex, @constructor.propertyIndices.reflectance, material.reflectance?.r ? 0, material.reflectance?.g ? 0, material.reflectance?.b ? 0, if material.reflectance then 1 else 0
      @_writeToData materialIndex, @constructor.propertyIndices.emission, material.emission?.r ? 0, material.emission?.g ? 0, material.emission?.b ? 0
      @_writeToData materialIndex, @constructor.propertyIndices.refractiveIndex, material.refractiveIndex?.r ? 0, material.refractiveIndex?.g ? 0, material.refractiveIndex?.b ? 0
      @_writeToData materialIndex, @constructor.propertyIndices.structure, material.surfaceRoughness ? 1, material.subsurfaceHeterogeneity ? 1, material.conductivity ? 0

    @needsUpdate = true
