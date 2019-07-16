LOI = LandsOfIllusions

class LOI.Engine.Materials.PreprocessingMaterial extends LOI.Engine.Materials.Material
  @id: -> 'LandsOfIllusions.Engine.Materials.PreprocessingMaterial'
  @initialize()

  constructor: (options) ->
    parameters =
      # Preprocessing information should come from the closest object so we shouldn't use blending.
      blending: THREE.NoBlending

      uniforms: _.extend
        # Color information
        ramp:
          value: options.ramp
        shade:
          value: options.shade
      ,
        # Texture
        LOI.Engine.Materials.RampMaterial.getTextureUniforms options
      ,
        # Translucency
        translucencyTint:
          value: options.translucency?.tint or false

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

uniform float ramp;
uniform float shade;

uniform bool translucencyTint;

#{LOI.Engine.Materials.ShaderChunks.readTextureDataParametersFragment}

void main()	{
  // Determine palette color (ramp and shade).
  vec2 paletteColor;

  // Discard transparent pixels for textured fragments.
  #ifdef USE_MAP
    #{LOI.Engine.Materials.ShaderChunks.readTextureDataFragment}
  #endif

  if (translucencyTint) {
    #ifndef USE_MAP
      // We're using constants, read from uniforms.
      #{LOI.Engine.Materials.ShaderChunks.setPaletteColorFromUniformsFragment}
    #endif

  } else {
    // No tinting is used, so set values to 1 (not used).
    paletteColor = vec2(1.0);
  }

  // Preprocessing map has the tint color (ramp and shade) written to red and green channels.
  gl_FragColor = vec4(paletteColor.r, paletteColor.g, 0.0, 0.0);
}
"""
    super parameters
    @options = options

    LOI.Engine.Materials.RampMaterial.updateTextures @ if @options.texture
