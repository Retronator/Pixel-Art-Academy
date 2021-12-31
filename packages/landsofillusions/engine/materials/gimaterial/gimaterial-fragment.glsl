// LandsOfIllusions.Engine.Materials.GIMaterial.fragment
#include <THREE>

#ifdef USE_MAP
  #include <uv_pars_fragment>
  #include <map_pars_fragment>
#endif

#include <Artificial.Pyramid.IntegerOperations>

// Globals
uniform vec2 renderSize;
uniform bool cameraParallelProjection;
uniform vec3 cameraDirection;

// Color information
uniform sampler2D palette;

// Texture
#include <LandsOfIllusions.Engine.Materials.readTextureDataParametersFragment>

// Illumination state
#include <LandsOfIllusions.Engine.IlluminationState.commonParametersFragment>

// Material properties
#include <LandsOfIllusions.Engine.Materials.materialPropertiesParametersFragment>

// Lightmap properties
#include <LandsOfIllusions.Engine.Materials.lightmapAreaPropertiesParametersFragment>

// Translucency
uniform float opacity;

varying vec2 vLightmapCoordinates;
varying float vCameraAngleW;

void main()	{
  // Read lightmap properties.
  vec2 lightmapAreaPosition = vec2(
    readLightmapAreaProperty(lightmapAreaPropertyPositionX),
    readLightmapAreaProperty(lightmapAreaPropertyPositionY)
  );

  float lightmapAreaSize = readLightmapAreaProperty(lightmapAreaPropertySize);
  float lightmapAreaActiveMipmapLevel = readLightmapAreaProperty(lightmapAreaPropertyActiveMipmapLevel);

  // Read illumination from the lightmap.
  vec2 lightmapCoordinates = (vLightmapCoordinates / vCameraAngleW + lightmapAreaPosition + vec2(0.5)) / lightmapSize;
  vec3 illumination = sampleLightmap(lightmapCoordinates, lightmapAreaActiveMipmapLevel, lightmapAreaPosition, lightmapAreaSize);

  // Shade local color with illumination.
  vec2 paletteColor;

  #ifdef USE_MAP
    #include <LandsOfIllusions.Engine.Materials.readTextureDataFragment>
    #include <LandsOfIllusions.Engine.Materials.unpackSamplePaletteColorFragment>

  #else
    #include <LandsOfIllusions.Engine.Materials.setPaletteColorFromMaterialPropertiesFragment>

  #endif

  // Get actual RGB values for this palette color.

  #include <LandsOfIllusions.Engine.Materials.readSourceColorFromPaletteFragment>

  vec3 linearSourceColor = sRGBToLinear(vec4(sourceColor, 1.0)).rgb;

  // Shade the source color.
  vec3 outputRadiance = linearSourceColor * illumination;

  // Add emmited light.
  vec3 emission = vec3(
    readMaterialProperty(materialPropertyEmissionR),
    readMaterialProperty(materialPropertyEmissionG),
    readMaterialProperty(materialPropertyEmissionB)
  );

  vec3 absorptance = 1.0 - linearSourceColor;
  outputRadiance += emission * absorptance;

  gl_FragColor = vec4(outputRadiance, 1);
}
