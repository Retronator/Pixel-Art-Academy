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

// Layer properties
#include <LandsOfIllusions.Engine.Materials.layerPropertiesParametersFragment>

// Translucency
uniform float opacity;

varying vec2 vLayerPixelCoordinates;
varying float vCameraAngleW;

void main()	{
  // Read layer properties.
  vec2 layerAtlasPosition = vec2(
    readLayerProperty(layerPropertyAtlasPositionX),
    readLayerProperty(layerPropertyAtlasPositionY)
  );

  vec2 layerSize = vec2(
    readLayerProperty(layerPropertyWidth),
    readLayerProperty(layerPropertyHeight)
  );

  // Find which illumination probe to use by sampling the probe map at pixel coordinates.
  vec2 layerPixelCoordinates = vLayerPixelCoordinates / vCameraAngleW;
  layerPixelCoordinates = floor(layerPixelCoordinates + 0.5);

  // Note: We need to use integer arithmetics to avoid rounding errors when computing probe coordinates.
  vec2 pixelPositionInAtlas = layerAtlasPosition + layerPixelCoordinates;
  int probeIndex = int(texture2D(probeMapAtlas, pixelPositionInAtlas / layerAtlasSize).a);
  int layerWidth = int(layerSize.x);
  vec2 probeCoordinates = vec2(
    mod(probeIndex, layerWidth),
    probeIndex / layerWidth
  );

  vec3 illumination = sampleIllumination(layerAtlasPosition, probeCoordinates);

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
