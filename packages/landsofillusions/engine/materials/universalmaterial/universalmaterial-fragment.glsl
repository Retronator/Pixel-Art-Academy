// LandsOfIllusions.Engine.Materials.UniversalMaterial.fragment
#include <THREE>

// General
#include <packing>
#include <LandsOfIllusions.Engine.Materials.ditherParametersFragment>
#include <Artificial.Pyramid.IntegerOperations>

// Globals
uniform vec2 renderSize;
uniform bool cameraParallelProjection;
uniform vec3 cameraDirection;

// Shading
uniform bool colorQuantization;
uniform float colorQuantizationFactor;

varying vec3 vViewPosition;

#include <LandsOfIllusions.Engine.Materials.totalLightIntensityParametersFragment>

#include <normal_pars_fragment>
#include <shadowmap_pars_fragment>
#include <lights_pars_begin>
#include <lights_physical_pars_fragment>

// Texture
#include <LandsOfIllusions.Engine.Materials.readTextureDataParametersFragment>
#ifdef USE_MAP
  #include <uv_pars_fragment>
  #include <map_pars_fragment>
  #include <normalmap_pars_fragment>
#endif

// Illumination state
#include <LandsOfIllusions.Engine.IlluminationState.commonParametersFragment>

// Material properties
#include <LandsOfIllusions.Engine.Materials.materialPropertiesParametersFragment>

// Lightmap area properties
#include <LandsOfIllusions.Engine.Materials.lightmapAreaPropertiesParametersFragment>

varying vec2 vLightmapCoordinates;
varying float vCameraAngleW;

// Color information
uniform sampler2D palette;
#include <LandsOfIllusions.Engine.Materials.paletteParametersFragment>

void main()	{
  // Immediately discard invisible pixels in dithered translucency.
  float translucencyDither = readMaterialProperty(materialPropertyTranslucencyDither);
  if (dither4levels(translucencyDither)) discard;

  // Read material properties.
  vec3 emissive;
  float roughness;
  float metalness;
  float opacity;
  vec3 ior;
  float specularIntensity;
  vec3 specularColor;

  vec2 paletteColor;

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
    // We're using constants, read from material properties.
    #include <LandsOfIllusions.Engine.Materials.setPaletteColorFromMaterialPropertiesFragment>
    reflectionParameters = vec3(
      readMaterialProperty(materialPropertyReflectionIntensity),
      readMaterialProperty(materialPropertyReflectionShininess),
      readMaterialProperty(materialPropertyReflectionSmoothFactor)
    );
    shadingDither = readMaterialProperty(materialPropertyDither);

  #endif

  // Get actual RGB values for this palette color.
  #include <LandsOfIllusions.Engine.Materials.readSourceColorFromPaletteFragment>

  vec3 diffuse = sRGBToLinear(vec4(sourceColor, 1.0)).rgb;
  vec4 diffuseColor = vec4( diffuse, opacity );

  ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
  vec3 totalEmissiveRadiance = emissive;

  float roughnessFactor = roughness;
  float metalnessFactor = metalness;

  vec3 normal = normalize( vNormal );
  vec3 geometryNormal = normal;

  // Set physical material properties.
  PhysicalMaterial material;

  // Diffuse color is the color of reflection from subsurface scattering. Albedo for dielectrics, nothing for metals.
  material.diffuseColor = diffuseColor.rgb * ( 1.0 - metalnessFactor );

  // Roughness defines how rough or smooth the surface is.
  material.roughness = max( roughnessFactor, 0.0525 );// 0.0525 corresponds to the base mip of a 256 cubemap.

  // We increase roughness based on how much normals differentiate as well (the roughenss parameter instead captures how rough the surface is on a microscopic level).
  vec3 dxy = max( abs( dFdx( geometryNormal ) ), abs( dFdy( geometryNormal ) ) );
  float geometryRoughness = max( max( dxy.x, dxy.y ), dxy.z );
  material.roughness += geometryRoughness;
  material.roughness = min( material.roughness, 1.0 );

  // Specular F90 is the amount of reflection at a grazing angle.
  material.specularF90 = 1.0;

  // Specular color is the amount of reflection at a perpendicular angle. Approximation based on IOR for dielectrics (4% at default 1.5 IOR), albedo for conductors.
  material.specularColor = mix( min( pow2( ( ior - 1.0 ) / ( ior + 1.0 ) ), vec3( 1.0 ) ), diffuseColor.rgb, metalnessFactor );

  // Accumulate direct lights and setup indirect ambient/probe light.
  #include <lights_fragment_begin>

  // Read lightmap properties.
  vec2 lightmapAreaPosition = vec2(
    readLightmapAreaProperty(lightmapAreaPropertyPositionX),
    readLightmapAreaProperty(lightmapAreaPropertyPositionY)
  );

  float lightmapAreaSize = readLightmapAreaProperty(lightmapAreaPropertySize);
  float lightmapAreaActiveMipmapLevel = readLightmapAreaProperty(lightmapAreaPropertyActiveMipmapLevel);

  // Read illumination from the lightmap.
  vec2 lightmapCoordinates = (vLightmapCoordinates / vCameraAngleW + lightmapAreaPosition + vec2(0.5)) / lightmapSize;
  irradiance += sampleLightmap(lightmapCoordinates, lightmapAreaActiveMipmapLevel, lightmapAreaPosition, lightmapAreaSize);

  // Accumulate indirect light.
  #include <lights_fragment_end>



  // Quantize the color.
  if (colorQuantization && colorQuantizationFactor > 0.0) {
    shadedColor = floor(shadedColor * colorQuantizationFactor + 0.5) / colorQuantizationFactor;
  }

  // Color the pixel with the best match from the palette.
  gl_FragColor = vec4(destinationColor, opacity);
}
