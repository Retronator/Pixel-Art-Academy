LOI = LandsOfIllusions

class LOI.Engine.Materials.UniversalMaterial extends LOI.Engine.Materials.Material
  @id: -> 'LandsOfIllusions.Engine.Materials.UniversalMaterial'
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

  @getTextureUniforms: (options) ->
    textureMapping = LOI.Engine.Materials.UniversalMaterial.createTextureMappingMatrices options.texture if options.texture

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
        material.normalMap = spriteTextures.normalTexture if material.uniforms.normalMap

        material.needsUpdate = true
        material._dependency.changed()

  constructor: (options) ->
    parameters =
      lights: true

      transparent: false

      defines:
        USE_ILLUMINATION_STATE: options.illuminationStateField?

      uniforms: _.extend
        # Globals
        renderSize:
          value: null
        cameraAngleMatrix:
          value: new THREE.Matrix4
        cameraParallelProjection:
          value: false
        cameraDirection:
          value: new THREE.Vector3

        # Color information
        palette:
          value: options.mesh.paletteTexture

        # Material properties
        materialProperties:
          value: options.mesh.materialProperties.texture

        # Lightmap area properties
        lightmapAreaProperties:
          value: options.mesh.lightmapAreaProperties.texture

        # Illumination state
        lightmap:
          value: null
        lightmapSize:
          value: new THREE.Vector2
        envMap:
          value: null
        envMapIntensity:
          value: 1

        # Light visibility
        lightVisibility:
          value:
            directSurface: true
            directSubsurface: true
            indirectSurface: true
            indirectSubsurface: true
            emissive: true

        # Color restrictions
        restrictColors:
          value:
            ramps: false
            shades: false
      ,
        # Texture
        LOI.Engine.Materials.UniversalMaterial.getTextureUniforms options
      ,
        normalMap:
          value: null
        normalScale:
          value: new THREE.Vector2 1, 1
      ,
        # Light sources
        THREE.UniformsLib.lights

    super parameters
    @options = options

    LOI.Engine.Materials.UniversalMaterial.updateTextures @ if @options.texture

    # Update illumination state.
    if @options.illuminationStateField
      Tracker.nonreactive =>
        Tracker.autorun =>
          return unless illuminationState = @options.illuminationStateField()

          @uniforms.lightmap.value = illuminationState.lightmap.texture

          lightmapSize = options.mesh.lightmapAreaProperties.lightmapSize()
          @uniforms.lightmapSize.value.set lightmapSize.width, lightmapSize.height

          @needsUpdate = true
          @_dependency.changed()
