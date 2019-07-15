LOI = LandsOfIllusions

class LOI.Engine.Materials.ShadowColorMaterial extends LOI.Engine.Materials.Material
  @id: -> 'LandsOfIllusions.Engine.Materials.ShadowColorMaterial'
  @initialize()

  constructor: (options) ->
    transparent = LOI.Engine.Materials.RampMaterial.getTransparentProperty options

    parameters =
      # Because single-sided surfaces cast shadow on the back side,
      # we need to render this shader only on back sides as well.
      side: if transparent then THREE.DoubleSide else THREE.BackSide

      # Shadow color should contain information from the closest object so
      # we need to completely overwrite previous values (including alpha).
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
        translucencyAmount:
          value: options.translucency?.amount or 0
        translucencyShadowDither:
          value: options.translucency?.shadow?.dither ? options.translucency?.dither or 0
        translucencyShadowTint:
          value: options.translucency?.shadow?.tint or false

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

uniform float translucencyAmount;
uniform float translucencyShadowDither;
uniform bool translucencyShadowTint;

#{LOI.Engine.Materials.ShaderChunks.readTextureDataParametersFragment}

void main()	{
  // Determine palette color (ramp and shade).
  vec2 paletteColor;

  // Discard transparent pixels for textured fragments.
  #ifdef USE_MAP
    #{LOI.Engine.Materials.ShaderChunks.readTextureDataFragment}
  #endif

  if (translucencyShadowTint) {
    #ifndef USE_MAP
      // We're using constants, read from uniforms.
      #{LOI.Engine.Materials.ShaderChunks.setPaletteColorFromUniformsFragment}
    #endif

  } else {
    // No tinting is used, so set values to 1 (not used).
    paletteColor = vec2(1.0);
  }

  // Shadow color map has the color (ramp and shade) written to red
  // and green channels, shadow dither in blue, and translucency amount in alpha.
  gl_FragColor = vec4(paletteColor.r, paletteColor.g, translucencyShadowDither, translucencyAmount);
}
"""
    super parameters
    @options = options

    LOI.Engine.Materials.RampMaterial.updateTextures @ if @options.texture
