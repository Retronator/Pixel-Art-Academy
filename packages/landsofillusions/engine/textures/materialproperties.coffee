LOI = LandsOfIllusions

class LOI.Engine.Textures.MaterialProperties extends LOI.Engine.Textures.Properties
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
    translucencyShadowDither: 9
    translucencyShadowTint: 10
    emissionR: 11
    emissionG: 12
    emissionB: 13

  @maxItems: 256
  @maxProperties: 16

  constructor: ->
    super LOI.Engine.Textures.MaterialProperties

  update: (materialProperties) ->
    materials = materialProperties.mesh.materials.getAll()

    for materialPropertiesEntry, materialIndex in materialProperties.getAll()
      if materialPropertiesEntry.paletteColor
        @_writeToData materialIndex, @constructor.propertyIndices.ramp, materialPropertiesEntry.paletteColor.ramp
        @_writeToData materialIndex, @constructor.propertyIndices.shade, materialPropertiesEntry.paletteColor.shade

      else if materialPropertiesEntry.materialIndex?
        material = materials[materialPropertiesEntry.materialIndex]
        @_writeToData materialIndex, @constructor.propertyIndices.ramp, material.ramp
        @_writeToData materialIndex, @constructor.propertyIndices.shade, material.shade
        @_writeToData materialIndex, @constructor.propertyIndices.dither, material.dither
        @_writeToData materialIndex, @constructor.propertyIndices.reflectionIntensity, material.reflection?.intensity or 0
        @_writeToData materialIndex, @constructor.propertyIndices.reflectionShininess, material.reflection?.shininess or 1
        @_writeToData materialIndex, @constructor.propertyIndices.reflectionSmoothFactor, material.reflection?.smoothFactor or 0
        @_writeToData materialIndex, @constructor.propertyIndices.translucencyAmount, material.translucency?.amount or 0
        @_writeToData materialIndex, @constructor.propertyIndices.translucencyDither, material.translucency?.dither or 0
        @_writeToData materialIndex, @constructor.propertyIndices.translucencyTint, material.translucency?.tint or false
        @_writeToData materialIndex, @constructor.propertyIndices.translucencyShadowDither, material.translucency?.shadow?.dither ? material.translucency?.dither or 0
        @_writeToData materialIndex, @constructor.propertyIndices.translucencyShadowTint, material.translucency?.shadow?.tint or false
        @_writeToData materialIndex, @constructor.propertyIndices.emissionR, material.emission?.r or 0
        @_writeToData materialIndex, @constructor.propertyIndices.emissionG, material.emission?.g or 0
        @_writeToData materialIndex, @constructor.propertyIndices.emissionB, material.emission?.b or 0

    @needsUpdate = true
