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
        options = LOI.Assets.Mesh.Material.createUniversalMaterialOptions materialPropertiesEntry.paletteColor

      else if materialPropertiesEntry.materialIndex?
        material = materials[materialPropertiesEntry.materialIndex]
        options = material.toUniversalMaterialOptions()

      @_writeToData materialIndex, @constructor.propertyIndices.paletteColor, options.ramp, options.shade
      @_writeToData materialIndex, @constructor.propertyIndices.dither, options.dither
      @_writeToData materialIndex, @constructor.propertyIndices.reflectionProperties, options.reflection.intensity, options.reflection.shininess, options.reflection.smoothFactor
      @_writeToData materialIndex, @constructor.propertyIndices.translucency, options.translucency.amount, options.translucency.dither, options.translucency.tint
      @_writeToData materialIndex, @constructor.propertyIndices.translucencyShadow, options.translucency.shadow.dither ? options.translucency.dither, options.translucency.shadow.tint
      @_writeToData materialIndex, @constructor.propertyIndices.reflectance, options.reflectance.r, options.reflectance.g, options.reflectance.b
      @_writeToData materialIndex, @constructor.propertyIndices.emission, options.emission.r, options.emission.g, options.emission.b
      @_writeToData materialIndex, @constructor.propertyIndices.refractiveIndex, options.refractiveIndex.r, options.refractiveIndex.g, options.refractiveIndex.b
      @_writeToData materialIndex, @constructor.propertyIndices.structure, options.surfaceRoughness, options.subsurfaceHeterogeneity, options.conductivity

    @needsUpdate = true
