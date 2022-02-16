LOI = LandsOfIllusions

class LOI.Engine.Materials.DepthMaterial extends LOI.Engine.Materials.Material
  @id: -> 'LandsOfIllusions.Engine.Materials.DepthMaterial'
  @initialize()

  constructor: (options) ->
    parameters =
      # Because surfaces cast shadow on the back side, we need to render this shader only on back sides as well.
      side: THREE.BackSide

      # Depth information should come from the closest object so we shouldn't use blending.
      blending: THREE.NoBlending

      uniforms:
        # Texture
        LOI.Engine.Materials.UniversalMaterial.getTextureUniforms options, false

    super parameters
    @options = options

    LOI.Engine.Materials.UniversalMaterial.updateTextures @ if @options.texture
