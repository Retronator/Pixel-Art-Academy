// LandsOfIllusions.Engine.Materials.ShadowColorMaterial.fragment
#include <THREE>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <packing>

#include <LandsOfIllusions.Engine.Materials.materialPropertiesParametersFragment>
#include <LandsOfIllusions.Engine.Materials.readTextureDataParametersFragment>

void main()	{
  // Read material properties.
  float translucencyAmount = readMaterialProperty(materialPropertyTranslucencyShadowTint);
  float translucencyShadowDither = readMaterialProperty(materialPropertyTranslucencyShadowDither);
  bool translucencyShadowTint = readMaterialProperty(materialPropertyTranslucencyShadowTint) > 0.5;

  // Determine palette color (ramp and shade).
  vec2 paletteColor;

  // Discard transparent pixels for textured fragments.
  #ifdef USE_MAP
    #include <LandsOfIllusions.Engine.Materials.readTextureDataFragment>
  #endif

  if (translucencyShadowTint) {
    #ifndef USE_MAP
      // We're using constants, read from uniforms.
      #include <LandsOfIllusions.Engine.Materials.setPaletteColorFromMaterialPropertiesFragment>
    #endif

  } else {
    // No tinting is used, so set values to 1 (not used).
    paletteColor = vec2(1.0);
  }

  // Shadow color map has the color (ramp and shade) written to red
  // and green channels, shadow dither in blue, and translucency amount in alpha.
  gl_FragColor = vec4(paletteColor.r, paletteColor.g, translucencyShadowDither, translucencyAmount);
}
