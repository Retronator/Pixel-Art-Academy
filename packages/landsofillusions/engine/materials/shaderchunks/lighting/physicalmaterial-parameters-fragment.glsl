// LandsOfIllusions.Engine.Materials.physicalMaterialParametersFragment
// Adapted from https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/lights_physical_pars_fragment.glsl.js

struct PhysicalMaterial {
  vec3 diffuseColor;
  vec3 specularColor;
  float roughness;
};

// Analytical approximation of the DFG LUT, one half of the
// split-sum approximation used in indirect specular lighting.
// via 'environmentBRDF' from "Physically Based Shading on Mobile"
// https://www.unrealengine.com/blog/physically-based-shading-on-mobile
vec2 DFGApprox(const in vec3 normal, const in vec3 viewDir, const in float roughness) {
  float dotNV = saturate(dot(normal, viewDir));

  const vec4 c0 = vec4(- 1, - 0.0275, - 0.572, 0.022);
  const vec4 c1 = vec4(1, 0.0425, 1.04, - 0.04);

  vec4 r = roughness * c0 + c1;
  float a004 = min(r.x * r.x, exp2(- 9.28 * dotNV)) * r.x + r.y;

  vec2 fab = vec2(- 1.04, 1.04) * a004 + r.zw;
  return fab;
}

vec3 EnvironmentBRDF(const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness) {
  vec2 fab = DFGApprox(normal, viewDir, roughness);
  return specularColor * fab.x + specularF90 * fab.y;
}

// Fdez-Agüera's "Multiple-Scattering Microfacet Model for Real-Time Image Based Lighting"
// Approximates multiscattering in order to preserve energy.
// http://www.jcgt.org/published/0008/01/03/
void computeMultiscattering(const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness, inout vec3 singleScatter, inout vec3 multiScatter) {
  vec2 fab = DFGApprox(normal, viewDir, roughness);

  vec3 FssEss = specularColor * fab.x + specularF90 * fab.y;

  float Ess = fab.x + fab.y;
  float Ems = 1.0 - Ess;

  vec3 Favg = specularColor + (1.0 - specularColor) * 0.047619;// 1/21
  vec3 Fms = FssEss * Favg / (1.0 - Ems * Favg);

  singleScatter += FssEss;
  multiScatter += Fms * Ems;
}

#if NUM_RECT_AREA_LIGHTS > 0
  void RE_Direct_RectArea_Physical(const in RectAreaLight rectAreaLight, const in GeometricContext geometry, const in PhysicalMaterial material, inout ReflectedLight reflectedLight) {
    vec3 normal = geometry.normal;
    vec3 viewDir = geometry.viewDir;
    vec3 position = geometry.position;
    vec3 lightPos = rectAreaLight.position;
    vec3 halfWidth = rectAreaLight.halfWidth;
    vec3 halfHeight = rectAreaLight.halfHeight;
    vec3 lightColor = rectAreaLight.color;
    float roughness = material.roughness;

    vec3 rectCoords[4];
    rectCoords[0] = lightPos + halfWidth - halfHeight;// counterclockwise; light shines in local neg z direction
    rectCoords[1] = lightPos - halfWidth - halfHeight;
    rectCoords[2] = lightPos - halfWidth + halfHeight;
    rectCoords[3] = lightPos + halfWidth + halfHeight;

    vec2 uv = LTC_Uv(normal, viewDir, roughness);

    vec4 t1 = texture2D(ltc_1, uv);
    vec4 t2 = texture2D(ltc_2, uv);

    mat3 mInv = mat3(
    vec3(t1.x, 0, t1.y),
    vec3(0, 1, 0),
    vec3(t1.z, 0, t1.w)
    );

    // LTC Fresnel Approximation by Stephen Hill
    // http://blog.selfshadow.com/publications/s2016-advances/s2016_ltc_fresnel.pdf
    vec3 fresnel = (material.specularColor * t2.x + (vec3(1.0) - material.specularColor) * t2.y);

    reflectedLight.directSpecular += lightColor * fresnel * LTC_Evaluate(normal, viewDir, position, mInv, rectCoords);
    reflectedLight.directDiffuse += lightColor * material.diffuseColor * LTC_Evaluate(normal, viewDir, position, mat3(1.0), rectCoords);
  }
#endif

vec3 F_Burley(const in float dotNV, const in float dotNL, const in float dotVH, const in float roughness) {
  float f90 = 0.5 + 2.0 * roughness * pow2(dotVH);
  vec3 lightScatter = F_Schlick(vec3(1.0), f90, dotNL);
  vec3 viewScatter = F_Schlick(vec3(1.0), f90, dotNV);
  return lightScatter * viewScatter;
}

void RE_Direct_Physical(const in IncidentLight directLight, const in GeometricContext geometry, const in PhysicalMaterial material, inout ReflectedLight reflectedLight) {
  float alpha = pow2(material.roughness);
  vec3 halfDirection = normalize(directLight.direction + geometry.viewDir);
  float dotNL = saturate(dot(geometry.normal, directLight.direction));
  float dotNV = saturate(dot(geometry.normal, geometry.viewDir));
  float dotNH = saturate(dot(geometry.normal, halfDirection));
  float dotVH = saturate(dot(geometry.viewDir, halfDirection));

  // Calculate the total amount of light arriving at the surface.
  vec3 lightAtSurface = dotNL * directLight.color;

  // For light reflected at the surface, we only consider microfacets pointed in the half
  // direction (those will reflect light perfectly from the light source into the camera).
  float microfacetDistributionInHalfDirection = D_GGX(alpha, dotNH);
  vec3 lightAtHalfDirectionMicrofacets = lightAtSurface * microfacetDistributionInHalfDirection;

  // Fresnel equations (via Schlik's approximation) determine how much light reflects at the surface.
  vec3 reflectanceAtHalfDirectionMicrofacets = F_Schlick(material.specularColor, 1.0, dotVH);
  vec3 reflectedLightTowardsViewer = lightAtHalfDirectionMicrofacets * reflectanceAtHalfDirectionMicrofacets;

  // Some of the rays from the light to the viewer will be obstructed by other microfacets.
  float rayVisibilityRatio = V_GGX_SmithCorrelated(alpha, dotNL, dotNV);
  vec3 reflectedLightReachingViewer = reflectedLightTowardsViewer * rayVisibilityRatio;

  // Add the amount to light reflected at the surface.
  reflectedLight.directSpecular += reflectedLightReachingViewer;

  // We use Burley's approximation to determine the amount of light that enters the material, scatters, and exits.
  vec3 subsurfaceReflectance = F_Burley(dotNV, dotNL, dotVH, material.roughness);
  vec3 subsurfaceScatteredLightWithoutAbsorption = lightAtSurface * subsurfaceReflectance;

  // Some of the light gets absorbed by the material, the rest is transmitted through.
  vec3 subsurfaceScatteredLight = subsurfaceScatteredLightWithoutAbsorption * material.diffuseColor;

  // Calculate the portion of light going into the camera direction.
  vec3 subsurfaceScatteredLightReachingViewer = BRDF_Lambert(subsurfaceScatteredLight);

  // Add the amount of light reflected through subsurface scattering.
  reflectedLight.directDiffuse += subsurfaceScatteredLightReachingViewer;
}

void RE_IndirectDiffuse_Physical(const in vec3 irradiance, const in GeometricContext geometry, const in PhysicalMaterial material, inout ReflectedLight reflectedLight) {
  // Indirect diffuse light from a lightmap accumulates here.
  reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert(material.diffuseColor);
}

void RE_IndirectSpecular_Physical(const in vec3 radiance, const in vec3 irradiance, const in vec3 clearcoatRadiance, const in GeometricContext geometry, const in PhysicalMaterial material, inout ReflectedLight reflectedLight) {
  // Both indirect specular and indirect diffuse IBL accumulate here.
  vec3 singleScattering = vec3(0.0);
  vec3 multiScattering = vec3(0.0);
  vec3 cosineWeightedIrradiance = irradiance * RECIPROCAL_PI;

  computeMultiscattering(geometry.normal, geometry.viewDir, material.specularColor, 1.0, material.roughness, singleScattering, multiScattering);

  vec3 diffuse = material.diffuseColor * (1.0 - (singleScattering + multiScattering));

  reflectedLight.indirectSpecular += radiance * singleScattering;
  reflectedLight.indirectSpecular += multiScattering * cosineWeightedIrradiance;

  reflectedLight.indirectDiffuse += diffuse * cosineWeightedIrradiance;
}

  #define RE_Direct             RE_Direct_Physical
  #define RE_Direct_RectArea    RE_Direct_RectArea_Physical
  #define RE_IndirectDiffuse    RE_IndirectDiffuse_Physical
  #define RE_IndirectSpecular   RE_IndirectSpecular_Physical

// ref: https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf
float computeSpecularOcclusion(const in float dotNV, const in float ambientOcclusion, const in float roughness) {
  return saturate(pow(dotNV + ambientOcclusion, exp2(- 16.0 * roughness - 1.0)) - 1.0 + ambientOcclusion);
}
