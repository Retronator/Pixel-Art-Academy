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
        LOI.Engine.Materials.RampMaterial.getTextureUniforms options

      vertexShader: """
#include <common>
#include <uv_pars_vertex>

#ifdef USE_MAP
  uniform mat3 textureMapping;
#endif

void main()	{
  #include <begin_vertex>
	#include <project_vertex>
  #include <worldpos_vertex>

  #{LOI.Engine.Materials.ShaderChunks.mapTextureVertex}
}
"""

      fragmentShader: """
#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <packing>

#{LOI.Engine.Materials.ShaderChunks.readTextureDataParametersFragment}

void main()	{
  // Discard transparent pixels for textured fragments.
  #ifdef USE_MAP
    vec2 paletteColor;
    #{LOI.Engine.Materials.ShaderChunks.readTextureDataFragment}
  #endif

  gl_FragColor = packDepthToRGBA(gl_FragCoord.z);
}
"""

    super parameters
    @options = options

    LOI.Engine.Materials.RampMaterial.updateTextures @ if @options.texture
