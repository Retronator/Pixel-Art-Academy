LOI = LandsOfIllusions

class LOI.Engine.Materials.RampMaterial extends LOI.Engine.Materials.Material
  @id: -> 'LandsOfIllusions.Engine.Materials.RampMaterial'
  @initialize()

  @createTextureMappingMatrices: (textureOptions) ->
    # Create the texture mapping matrix.
    elements = [1, 0, 0, 0, 1, 0, 0, 0, 1]

    if textureOptions.mappingMatrix
      elements = _.defaults [], textureOptions.mappingMatrix, elements

    mapping = new THREE.Matrix3().set elements...

    offset = new THREE.Matrix3()
    offset.elements[6] = textureOptions.mappingOffset?.x or 0
    offset.elements[7] = textureOptions.mappingOffset?.y or 0

    {mapping, offset}

  @getTransparentProperty: (options) ->
    # Note: We make dithered materials transparent too (even though this is not
    # required for rendering) so that they get properly hidden for opaque shadow map.
    options.translucency?.amount or options.translucency?.dither

  @getTextureUniforms: (options) ->
    textureMapping = LOI.Engine.Materials.RampMaterial.createTextureMappingMatrices options.texture if options.texture

    map:
      value: null
    powerOf2Texture:
      value: null
    textureMapping:
      value: textureMapping?.mapping
    uvTransform:
      value: textureMapping?.offset
    mipmapBias:
      value: options.texture?.mipmapBias or 0

  @updateTextures: (material) ->
    spriteTextures = LOI.Engine.Textures.getTextures material.options.texture

    Tracker.nonreactive =>
      Tracker.autorun =>
        spriteTextures.depend()

        material.uniforms.map.value = spriteTextures.paletteColorTexture
        material.uniforms.normalMap.value = spriteTextures.normalTexture if material.uniforms.normalMap
        material.uniforms.powerOf2Texture.value = spriteTextures.isPowerOf2

        # Maps need to be set on the object itself as well for shader defines to kick in.
        material.map = spriteTextures.paletteColorTexture
        material.normalMap = spriteTextures.normalTexture  if material.uniforms.normalMap

        material.needsUpdate = true
        material._dependency.changed()

  constructor: (options) ->
    paletteTexture = new LOI.Engine.Textures.Palette options.palette

    transparent = LOI.Engine.Materials.RampMaterial.getTransparentProperty options

    parameters =
      lights: true

      # Note: We need the transparent property to be a boolean since it's compared by equality against true/false.
      transparent: transparent > 0

      uniforms: _.extend
        # Globals
        renderSize:
          value: null

        # Color information
        ramp:
          value: options.ramp
        shade:
          value: options.shade
        dither:
          value: options.dither
        palette:
          value: paletteTexture

        # Reflection
        reflectionIntensity:
          value: options.reflection?.intensity
        reflectionShininess:
          value: options.reflection?.shininess or 1
        reflectionSmoothFactor:
          value: options.reflection?.smoothFactor

        # Shading
        smoothShading:
          value: options.smoothShading
        smoothShadingQuantizationFactor:
          value: options.smoothShadingQuantizationFactor
        directionalShadowColorMap:
          value: []
        directionalOpaqueShadowMap:
          value: []
        preprocessingMap:
          value: null
      ,
        # Texture
        LOI.Engine.Materials.RampMaterial.getTextureUniforms options
      ,
        normalMap:
          value: null
        normalScale:
          value: new THREE.Vector2 1, 1

        # Translucency
        opacity:
          value: 1 - (options.translucency?.amount or 0)
        translucencyDither:
          value: options.translucency?.dither or 0
      ,
        THREE.UniformsLib.lights

    blending = options.translucency?.blending

    if transparent and blending
      parameters.blending = THREE[blending.preset] if blending.preset?
      parameters.blendEquation = THREE[blending.equation] if blending.equation?
      parameters.blendSrc = THREE[blending.sourceFactor] if blending.sourceFactor?
      parameters.blendDst = THREE[blending.destinationFactor] if blending.destinationFactor?

    super parameters
    @options = options

    LOI.Engine.Materials.RampMaterial.updateTextures @ if @options.texture
