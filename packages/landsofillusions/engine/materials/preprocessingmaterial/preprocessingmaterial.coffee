LOI = LandsOfIllusions

class LOI.Engine.Materials.PreprocessingMaterial extends LOI.Engine.Materials.Material
  @id: -> 'LandsOfIllusions.Engine.Materials.PreprocessingMaterial'
  @initialize()

  constructor: (options) ->
    parameters =
      # Preprocessing information should come from the closest object so we shouldn't use blending.
      blending: THREE.NoBlending

      uniforms: _.extend
        # Material properties
        materialProperties:
          value: options.mesh.materialProperties.texture
      ,
        # Texture
        LOI.Engine.Materials.RampMaterial.getTextureUniforms options

    super parameters
    @options = options

    LOI.Engine.Materials.RampMaterial.updateTextures @ if @options.texture
