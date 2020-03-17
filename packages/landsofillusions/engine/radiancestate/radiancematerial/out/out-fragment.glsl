// LandsOfIllusions.Engine.RadianceState.RadianceMaterial.Out.fragment
#include <LandsOfIllusions.Engine.RadianceState.RadianceMaterial.paremetersFragment>

#include <Artificial.Reality.Optics.FresnelEquations>

// Material information
uniform vec3 refractiveIndex;
uniform vec3 extinctionCoefficient;
uniform vec3 emission;
uniform vec3 albedo;

void main() {
  // Sample across the whole hemisphere.
  const float sampleLevel = 0.0;

  const float samplesPerSide = 1.0;
  const float sampleSpacing = 1.0 / samplesPerSide;
  const float samples = samplesPerSide * samplesPerSide;

  const float hemisphereSolidAngle = 2.0 * PI;
  const float sampleSolidAngle = hemisphereSolidAngle / samples;

  vec2 octahedronMapPosition;
  vec3 direction;
  vec3 normal = vec3(0, 0, 1);

  vec3 irradiance;

  for (float x = 0.5; x < samplesPerSide; x++) {
    for (float y = 0.5; y < samplesPerSide; y++) {
      octahedronMapPosition = vec2(x * sampleSpacing, y * sampleSpacing * 0.5);
      direction = octahedronMapToDirection(octahedronMapPosition);
      irradiance += sampleProbe(octahedronMapPosition, sampleLevel).rgb * saturate(dot(direction, normal)) * sampleSolidAngle;
    }
  }

  vec3 outDirection = octahedronMapToDirection(vUv);
  float cosAngleOfIncidnce = dot(normal, outDirection);
  float angleOfIncidence = acos(cosAngleOfIncidnce);

  vec3 reflectance, absorptance;

  if (albedo.r < 0.0) {
    // We have a phyisicaly based material. Calculate reflectance and absorptance
    // from refractive index and extinction coefficient using Fresnel equations.
    reflectance = FresnelEquations_getReflectance(angleOfIncidence, vec3(1.0), refractiveIndex, vec3(0.0), extinctionCoefficient);
    absorptance = FresnelEquations_getAbsorptance(angleOfIncidence, vec3(1.0), refractiveIndex, vec3(0.0), extinctionCoefficient);
  } else {
    // We have an ad-hoc material. Calculate reflectance and absorptance based on
    // the albedo and Schlick's approximation instead of actual Fresnel equations.
    reflectance = albedo;
    absorptance = 1.0 - reflectance;
  }

  // Output reflected light.
  vec3 outputRadiance = irradiance / hemisphereSolidAngle * reflectance;

  // Add emmited light.
  outputRadiance += emission * absorptance;

  gl_FragColor = vec4(outputRadiance, 1);
}
