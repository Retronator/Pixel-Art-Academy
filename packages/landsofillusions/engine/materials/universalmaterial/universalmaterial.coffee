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

  @getTextureUniforms: (options, normalMap = true) ->
    textureMapping = LOI.Engine.Materials.UniversalMaterial.createTextureMappingMatrices options.texture if options.texture

    uniforms =
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

    if normalMap
      _.extend uniforms,
        normalMap:
          value: null
        normalScale:
          value: new THREE.Vector2 1, 1

    uniforms

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

      uniforms: _.extend
        # Globals
        renderSize:
          value: null

        # Camera
        cameraAngleMatrix:
          value: new THREE.Matrix4
        cameraParallelProjection:
          value: false
        cameraDirection:
          value: new THREE.Vector3

        # Color palette
        palette:
          value: options.mesh.paletteTexture

        # Material properties
        materialProperties:
          value: options.mesh.materialProperties.texture
      ,
        # Textures
        LOI.Engine.Materials.UniversalMaterial.getTextureUniforms options
      ,
        # Light visibility
        lightVisibility:
          value:
            directSurface: true
            directSubsurface: true
            indirectSurface: true
            indirectSubsurface: true
            emissive: true
      ,
        # Geometric lights
        THREE.UniformsLib.lights
      ,
        # Lightmap
        lightmap:
          value: null
        lightmapSize:
          value: new THREE.Vector2
        lightmapAreaProperties:
          value: options.mesh.lightmapAreaProperties.texture

        # Environment map
        envMap:
          value: null
        envMapIntensity:
          value: 1

        # Color restrictions
        restrictColors:
          value:
            ramps: false
            shades: false

    super parameters
    @options = options

    LOI.Engine.Materials.UniversalMaterial.updateTextures @ if @options.texture
