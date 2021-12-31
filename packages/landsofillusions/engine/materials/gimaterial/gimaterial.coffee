AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions

class LOI.Engine.Materials.GIMaterial extends LOI.Engine.Materials.Material
  @id: -> 'LandsOfIllusions.Engine.Materials.GIMaterial'
  @initialize()

  constructor: (options) ->
    parameters =
      lights: false

      extensions:
        shaderTextureLOD: true

      uniforms: _.extend
        # Globals
        renderSize:
          value: new THREE.Vector2 1, 1
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

        # Layer properties
        lightmapAreaProperties:
          value: options.mesh.lightmapAreaProperties.texture
      ,
        # Texture
        if options.texture then LOI.Engine.Materials.RampMaterial.getTextureUniforms(options) else {}
      ,
        # Illumination state
        lightmap:
          value: null
        lightmapSize:
          value: new THREE.Vector2

    super parameters
    @options = options

    LOI.Engine.Materials.RampMaterial.updateTextures @ if @options.texture

    # Update illumination state.
    Tracker.nonreactive =>
      Tracker.autorun =>
        return unless illuminationState = @options.illuminationStateField()

        @uniforms.lightmap.value = illuminationState.lightmap.texture

        lightmapSize = options.mesh.lightmapAreaProperties.lightmapSize()
        @uniforms.lightmapSize.value.set lightmapSize.width, lightmapSize.height

        @needsUpdate = true
        @_dependency.changed()
