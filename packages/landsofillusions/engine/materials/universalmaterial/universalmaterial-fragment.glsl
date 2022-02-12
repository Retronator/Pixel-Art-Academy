// LandsOfIllusions.Engine.Materials.UniversalMaterial.fragment
#include <THREE>

#define STANDARD
#define IOR
#define SPECULAR

// General
#include <packing>
#include <LandsOfIllusions.Engine.Materials.ditherParametersFragment>
#include <Artificial.Reality.Optics.FresnelEquations>

// Globals
uniform vec2 renderSize;
uniform bool cameraParallelProjection;
uniform vec3 cameraDirection;

// Shading
varying vec3 vViewPosition;

#include <bsdfs>
#include <cube_uv_reflection_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_physical_pars_fragment>
#include <normal_pars_fragment>
#include <shadowmap_pars_fragment>
#include <lights_pars_begin>

#include <LandsOfIllusions.Engine.Materials.physicalMaterialParametersFragment>

// Light visibility
struct LightVisibility {
  bool directSurface;
  bool directSubsurface;
  bool indirectSurface;
  bool indirectSubsurface;
  bool emissive;
};

uniform LightVisibility lightVisibility;

// Texture
#ifdef USE_MAP
  #include <uv_pars_fragment>
  #include <map_pars_fragment>
  #include <normalmap_pars_fragment>
#endif

#include <LandsOfIllusions.Engine.Materials.readTextureDataParametersFragment>

// Illumination state
#ifdef USE_ILLUMINATION_STATE
  #include <LandsOfIllusions.Engine.IlluminationState.commonParametersFragment>
#endif

// Material properties
#include <LandsOfIllusions.Engine.Materials.materialPropertiesParametersFragment>

// Lightmap area properties
#ifdef USE_ILLUMINATION_STATE
  #include <LandsOfIllusions.Engine.Materials.lightmapAreaPropertiesParametersFragment>
#endif

varying vec2 vLightmapCoordinates;
varying float vCameraAngleW;

// Color information
uniform sampler2D palette;
#include <LandsOfIllusions.Engine.Materials.paletteParametersFragment>

void main() {

  // Immediately discard invisible pixels in dithered translucency.
  vec3 translucency = readMaterialProperty3(materialPropertyTranslucency);
  float translucencyDither = translucency.y;
  if (dither4levels(translucencyDither)) discard;

  // Set the normal.
  vec3 normal = normalize(vNormal);
  vec3 geometryNormal = normal;

  // Set physical material properties.
  PhysicalMaterial material;

  vec3 structure = readMaterialProperty3(materialPropertyStructure);
  float roughness = structure.x;
  float conductivity = structure.z;

  // Roughness defines how rough or smooth the surface is.
  material.roughness = max(roughness, 0.0525);// 0.0525 corresponds to the base mip of a 256 cubemap.

  // We increase roughness based on how much normals differentiate as well (the roughenss parameter instead captures how rough the surface is on a microscopic level).
  vec3 dxy = max(abs(dFdx(geometryNormal)), abs(dFdy(geometryNormal)));
  float geometryRoughness = max(max(dxy.x, dxy.y), dxy.z);
  material.roughness += geometryRoughness;
  material.roughness = min(material.roughness, 1.0);

  // Get the color of the material from the palette.
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
    reflectionParameters = readMaterialProperty3(materialPropertyReflection);
    shadingDither = readMaterialProperty(materialPropertyDither);

  #endif

  // Get actual RGB values for this palette color.
  #include <LandsOfIllusions.Engine.Materials.readSourceColorFromPaletteFragment>

  // Materials can be defined physically by their fully-defined refractive indices (rgb) or manually by setting a
  // constant refractive index (in r). We don't really need the full refractive index for physical materials because
  // we have the reflectance precalculated for normal incidence, but we still use refractive index to see if it's
  // defined for all three components or just the constant.
  vec3 refractiveIndex = readMaterialProperty3(materialPropertyRefractiveIndex);
  bool isPhysicalMaterial = refractiveIndex.b > 0.0;

  // Specular color is the amount of light reflected at the surface.
  vec3 reflectance;

  if (isPhysicalMaterial) {
    // We have a physical material with precomputed reflectance at normal incidence.
    reflectance = readMaterialProperty3(materialPropertyReflectance);

  } else {
    // We only have the palette color defined, which specifies the color for conductors.
    vec3 conductorReflectance = sourceColor;

    // Dielectrics calculate reflectance from the refractive index, conductors from the palette color.
    float reflectanceValue = pow2((refractiveIndex.r - 1.0) / (refractiveIndex.r + 1.0));
    vec3 dielectricReflectance = vec3(reflectanceValue);

    reflectance = mix(dielectricReflectance, conductorReflectance, conductivity);
  }

  material.specularColor = reflectance;

  // Diffuse color describes which light gets transmitted inside the material (none for conductors).
  material.diffuseColor = sourceColor * (1.0 - conductivity);

  // Accumulate direct lights and setup indirect ambient/probe light.
  ReflectedLight reflectedLight = ReflectedLight(vec3(0.0), vec3(0.0), vec3(0.0), vec3(0.0));
  #include <lights_fragment_begin>

  #ifdef USE_ILLUMINATION_STATE
    // Read lightmap properties.
    vec2 lightmapAreaPosition = readLightmapAreaProperty2(lightmapAreaPropertyPosition);
    float lightmapAreaSize = readLightmapAreaProperty(lightmapAreaPropertySize);
    float lightmapAreaActiveMipmapLevel = readLightmapAreaProperty(lightmapAreaPropertyActiveMipmapLevel);

    // Read illumination from the lightmap.
    vec2 lightmapCoordinates = (vLightmapCoordinates / vCameraAngleW + lightmapAreaPosition + vec2(0.5)) / lightmapSize;
    irradiance += sampleLightmap(lightmapCoordinates, lightmapAreaActiveMipmapLevel, lightmapAreaPosition, lightmapAreaSize);
  #endif

  // Accumulate indirect light.
  #include <lights_fragment_maps>
  #include <lights_fragment_end>

  // Sum the total outgoing radiance.
  vec3 totalRadiance;
  if (lightVisibility.directSurface) totalRadiance += reflectedLight.directSpecular;
  if (lightVisibility.directSubsurface) totalRadiance += reflectedLight.directDiffuse;
  if (lightVisibility.indirectSurface) totalRadiance += reflectedLight.indirectSpecular;
  if (lightVisibility.indirectSubsurface) totalRadiance += reflectedLight.indirectDiffuse;

  // Add light emmited from the material.
  vec3 totalEmissiveRadiance = readMaterialProperty3(materialPropertyEmission);
  if (lightVisibility.emissive) totalRadiance += totalEmissiveRadiance;

  // Output the radiance.
  gl_FragColor = vec4(totalRadiance, 1.0);

  #include <tonemapping_fragment>
  #include <encodings_fragment>
}
