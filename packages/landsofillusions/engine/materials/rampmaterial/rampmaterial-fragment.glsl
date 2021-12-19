// LandsOfIllusions.Engine.Materials.RampMaterial.fragment
#include <THREE>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <normalmap_pars_fragment>
#include <packing>
#include <lights_pars_begin>
#include <shadowmap_pars_fragment>

#include <LandsOfIllusions.Engine.Materials.ditherParametersFragment>

// Globals
uniform vec2 renderSize;

// Color information
uniform sampler2D palette;
#include <LandsOfIllusions.Engine.Materials.paletteParametersFragment>

// Shading
uniform bool smoothShading;
uniform float smoothShadingQuantizationFactor;
#include <LandsOfIllusions.Engine.Materials.totalLightIntensityParametersFragment>
uniform sampler2D preprocessingMap;

// Material properties
#include <LandsOfIllusions.Engine.Materials.materialPropertiesParametersFragment>

// Texture
#include <LandsOfIllusions.Engine.Materials.readTextureDataParametersFragment>

// Translucency
uniform float opacity;

varying vec3 vNormal;
varying vec3 vViewPosition;

void main()	{
  // Apply translucency dither first since that can discard the whole fragment altogether.
  float translucencyDither = readMaterialProperty(materialPropertyTranslucencyDither);
  if (dither4levels(translucencyDither)) discard;

  // Prepare normal.
  #include <normal_fragment_begin>

  // Determine palette color (ramp and shade), reflection parameters (amount, shininess, smoothFactor), and dither.
  vec2 paletteColor;
  vec3 reflectionParameters;
  float shadingDither;

  #ifdef USE_MAP
    #include <LandsOfIllusions.Engine.Materials.readTextureDataFragment>
    #include <LandsOfIllusions.Engine.Materials.unpackSamplePaletteColorFragment>
    #include <LandsOfIllusions.Engine.Materials.unpackSampleReflectionParametersFragment>
    #include <LandsOfIllusions.Engine.Materials.unpackSampleShadingDitherFragment>

  #else
    // We're using constants, read from uniforms.
    #include <LandsOfIllusions.Engine.Materials.setPaletteColorFromMaterialPropertiesFragment>
    reflectionParameters = vec3(
      readMaterialProperty(materialPropertyReflectionIntensity),
      readMaterialProperty(materialPropertyReflectionShininess),
      readMaterialProperty(materialPropertyReflectionSmoothFactor)
    );
    shadingDither = readMaterialProperty(materialPropertyDither);

  #endif

  // Calculate total light intensity. This step also tints the palette color based
  // on shadow color, so we have to do it before applying tinting in preprocessing.
  float shadowBiasOffset = 0.0;
  #include <LandsOfIllusions.Engine.Materials.totalLightIntensityFragment>

  // Apply preprocessing info.
  #include <LandsOfIllusions.Engine.Materials.applyPreprocessingFragment>

  // Get actual RGB values for this palette color.
  #include <LandsOfIllusions.Engine.Materials.readSourceColorFromPaletteFragment>

  // Calculate the shaded color.
  #include <LandsOfIllusions.Engine.Materials.shadeSourceColorFragment>

  // Quantize if set for smooth shading.
  #include <LandsOfIllusions.Engine.Materials.quantizeShadedColorFragment>

  // Bound shaded color to palette ramp.
  vec3 destinationColor = boundColorToPaletteRamp(shadedColor, paletteColor.r, shadingDither, smoothShading);

  // Color the pixel with the best match from the palette.
  gl_FragColor = vec4(destinationColor, opacity);
}
