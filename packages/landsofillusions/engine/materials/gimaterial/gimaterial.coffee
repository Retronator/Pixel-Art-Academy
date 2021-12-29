AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions

class LOI.Engine.Materials.GIMaterial extends LOI.Engine.Materials.Material
  @id: -> 'LandsOfIllusions.Engine.Materials.GIMaterial'
  @initialize()

  constructor: (options) ->
    parameters =
      lights: false

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
        layerProperties:
          value: options.mesh.layerProperties.texture
      ,
        # Texture
        if options.texture then LOI.Engine.Materials.RampMaterial.getTextureUniforms(options) else {}
      ,
        # Illumination state
        illuminationAtlas:
          value: null
        probeMapAtlas:
          value: null
        layerAtlasSize:
          value: new THREE.Vector2

    super parameters
    @options = options

    LOI.Engine.Materials.RampMaterial.updateTextures @ if @options.texture

    # Update illumination state.
    Tracker.nonreactive =>
      Tracker.autorun =>
        return unless illuminationState = @options.illuminationStateField()

        @uniforms.illuminationAtlas.value = illuminationState.illuminationAtlas.texture
        @uniforms.probeMapAtlas.value = illuminationState.probeMapAtlas.texture

        layerAtlasSize = options.mesh.layerProperties.layerAtlasSize()
        @uniforms.layerAtlasSize.value.set layerAtlasSize.width, layerAtlasSize.height

        @needsUpdate = true
        @_dependency.changed()
