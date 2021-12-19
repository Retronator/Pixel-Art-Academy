LOI = LandsOfIllusions

class LOI.Engine.Materials.ShadowColorMaterial extends LOI.Engine.Materials.Material
  @id: -> 'LandsOfIllusions.Engine.Materials.ShadowColorMaterial'
  @initialize()

  constructor: (options) ->
    parameters =
      # Because surfaces cast shadow on the back side, we need to render this shader only on back sides as well.
      side: THREE.BackSide

      # Shadow color information should come from the closest object so we shouldn't use blending.
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
