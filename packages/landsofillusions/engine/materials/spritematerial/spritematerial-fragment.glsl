// LandsOfIllusions.Engine.Materials.SpriteMaterial.fragment
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

uniform mat4 modelViewMatrix;
varying vec3 vViewPosition;

void main()	{
  // Read palette color from main map.
  vec4 sample = texture2D(map, vUv);

  // Discard transparent pixels.
  if (sample.a < 1.0) discard;

  // Unpack sample palette color and reflection parameters.
  vec2 paletteColor;
  vec3 reflectionParameters;
  #include <LandsOfIllusions.Engine.Materials.unpackSamplePaletteColorFragment>
  #include <LandsOfIllusions.Engine.Materials.unpackSampleReflectionParametersFragment>

  // Read normal from normal map.
  vec3 spriteNormal = texture2D(normalMap, vUv).xyz * 2.0 - 1.0;
  vec3 normal = normalize((modelViewMatrix * vec4(spriteNormal, 0.0)).xyz);

  // Calculate total light intensity. This step also tints the palette color based
  // on shadow color, so we have to do it before applying tinting in preprocessing.
  float shadowBiasOffset = -0.001;
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
  float ramp = paletteColor.r;
  float shadingDither;
  #include <LandsOfIllusions.Engine.Materials.unpackSampleShadingDitherFragment>

  vec3 destinationColor = boundColorToPaletteRamp(shadedColor, ramp, shadingDither, smoothShading);

  // Color the pixel with the best match from the palette.
  gl_FragColor = vec4(destinationColor, 1);
}
