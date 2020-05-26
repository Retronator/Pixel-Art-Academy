// LandsOfIllusions.Engine.RadianceState.RadianceMaterial.Out.fragment
#include <LandsOfIllusions.Engine.RadianceState.RadianceMaterial.paremetersFragment>
#include <Artificial.Reality.Optics.FresnelEquations>

const float hemisphereSolidAngle = 2.0 * PI;

// Material information
uniform vec3 refractiveIndex;
uniform vec3 extinctionCoefficient;
uniform vec3 emission;
uniform vec3 albedo;

void main() {
  vec2 outOctahedronMapPosition = vUv;
  vec3 outDirection = OctahedronMap_positionToDirection(outOctahedronMapPosition);
  bool outGoesIntoMaterial = outOctahedronMapPosition.y > 0.5;

  // Calculate geometry of the reflection.
  vec3 inDirection = vec3(outDirection.x, outDirection.y, -outDirection.z); // = reflect(outDirection, [0, 0, 1]);
  float cosAngleOfIncidence = outDirection.z; // = [0, 0, 1] ⋅ outDirection
  float angleOfIncidence = acos(cosAngleOfIncidence);

  // Based on roughness, determine how big of a solid angle to sample.
  float sampleLevel = 0.0;
  float samplesPerSide = pow(2.0, sampleLevel);
  float samplesPerHemisphere = pow2(samplesPerSide);
  float sampleSolidAngle = hemisphereSolidAngle / samplesPerHemisphere;

  // Get irradiance coming from incoming direction.
  vec3 irradiance = sampleProbe(-inDirection, sampleLevel).rgb;

  // Calculate reflectance and absorptance of the material.
  vec3 reflectance, absorptance;

  if (albedo.r < 0.0) {
    // We have a phyisicaly based material. Calculate reflectance and absorptance
    // from refractive index and extinction coefficient using Fresnel equations.
    vec3 n1 = vec3(1.0);
    vec3 n2 = vec3(1.0);
    vec3 k1 = vec3(0.0);
    vec3 k2 = vec3(0.0);

    if (outGoesIntoMaterial) {
      n1 = refractiveIndex;
      k1 = extinctionCoefficient;
    } else {
      n2 = refractiveIndex;
      k2 = extinctionCoefficient;
    }

    FresnelEquations_getReflectanceAndAbsorptance(angleOfIncidence, n1, n2, k1, k2, reflectance, absorptance);
  } else {
    // We have an ad-hoc material. Calculate reflectance and absorptance based on
    // the albedo and Schlick's approximation instead of actual Fresnel equations.
    // TODO: Uncomment to use Schlick's approximation when specular reflections are implemented.
    // reflectance = mix(albedo, vec3(1.0), pow(1.0 - cosAngleOfIncidnce, 5.0));
    reflectance = albedo;
    absorptance = 1.0 - reflectance;
  }

  // Output reflected light.
  vec3 outputRadiance = irradiance / hemisphereSolidAngle * reflectance;

  // Add emmited light.
  outputRadiance += emission * absorptance;

  gl_FragColor = vec4(outputRadiance, 1);
}
