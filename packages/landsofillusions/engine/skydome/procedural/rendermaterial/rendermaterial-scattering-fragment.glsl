// LandsOfIllusions.Engine.Skydome.Procedural.RenderMaterial.Scattering.fragment
#include <LandsOfIllusions.Engine.Skydome.Procedural.RenderMaterial.parametersFragment>

#include <Artificial.Reality.Optics.Scattering>

const int starRaySteps = 32;

void main() {
  vec2 octahedronMapPosition = vec2(vUv.x, vUv.y / 2.0);
  vec3 viewDirection = normalize(OctahedronMap_positionToDirection(octahedronMapPosition));
  vec3 viewpoint = vec3(0, 0, planetRadius + 1.0);
  vec3 starRayDirection = -starDirection;
  float starViewAngle = acos(dot(viewDirection, starRayDirection));

  vec3 totalRayleighAttenuationDensityFactor;
  vec3 totalMieAttenuationDensityFactor;

  // See how far the view ray reaches before it exits the atmosphere or hits the planet.
  float viewRayLengthThroughAtmosphere = getLengthThroughAtmosphere(viewpoint, viewDirection);
  float viewRayStepSize = viewRayLengthThroughAtmosphere / float(viewRaySteps);

  float viewRayTotalRayleighDensityRatio = 0.0;
  float viewRayTotalMieDensityRatio = 0.0;

  for (int viewRayStepCount = 0; viewRayStepCount < viewRaySteps; viewRayStepCount++) {
    float viewRayStepMiddleDistance = (float(viewRayStepCount) + 0.5) * viewRayStepSize;
    vec3 viewRayStepMiddlePosition = viewpoint + viewDirection * viewRayStepMiddleDistance;
    float viewRayStepMiddleHeight = length(viewRayStepMiddlePosition) - planetRadius;
    float viewRayStepMiddleRayleighDensityRatio = exp(-viewRayStepMiddleHeight / atmosphereRayleighScaleHeight);
    float viewRayStepMiddleMieDensityRatio = exp(-viewRayStepMiddleHeight / atmosphereMieScaleHeight);
    viewRayTotalRayleighDensityRatio += viewRayStepMiddleRayleighDensityRatio * 0.5;
    viewRayTotalMieDensityRatio += viewRayStepMiddleMieDensityRatio * 0.5;

    // Calculate the density ratio along the star ray, if we can see the star.
    if (!intersectsPlanet(viewRayStepMiddlePosition, starRayDirection)) {
      float starRayLengthThroughAtmosphere = getLengthThroughAtmosphere(viewRayStepMiddlePosition, starRayDirection);
      float starRayStepSize = starRayLengthThroughAtmosphere / float(starRaySteps);

      float starRayTotalRayleighDensityRatio = 0.0;
      float starRayTotalMieDensityRatio = 0.0;

      for (int starRayStepCount = 0; starRayStepCount < starRaySteps; starRayStepCount++) {
        float starRayStepMiddleDistance = (float(starRayStepCount) + 0.5) * starRayStepSize;
        vec3 starRayStepMiddlePosition = viewRayStepMiddlePosition + starRayDirection * starRayStepMiddleDistance;
        float starRayStepMiddleHeight = length(starRayStepMiddlePosition) - planetRadius;
        float starRayStepMiddleRayleighDensityRatio = exp(-starRayStepMiddleHeight / atmosphereRayleighScaleHeight);
        float starRayStepMiddleMieDensityRatio = exp(-starRayStepMiddleHeight / atmosphereMieScaleHeight);
        starRayTotalRayleighDensityRatio += starRayStepMiddleRayleighDensityRatio;
        starRayTotalMieDensityRatio += starRayStepMiddleMieDensityRatio;
      }
      
      vec3 viewRayRayleighScatteringCoefficient = atmosphereRayleighScatteringCoefficientSurface * viewRayTotalRayleighDensityRatio;
      float viewRayMieScatteringCoefficient = atmosphereMieScatteringCoefficientSurface * viewRayTotalMieDensityRatio;
      vec3 viewRayOpticalDepth = viewRayStepSize * (viewRayRayleighScatteringCoefficient + viewRayMieScatteringCoefficient);

      vec3 starRayRayleighScatteringCoefficient = atmosphereRayleighScatteringCoefficientSurface * starRayTotalRayleighDensityRatio;
      float starRayMieScatteringCoefficient = atmosphereMieScatteringCoefficientSurface * starRayTotalMieDensityRatio;
      vec3 starRayOpticalDepth = starRayStepSize * (starRayRayleighScatteringCoefficient + starRayMieScatteringCoefficient);

      vec3 opticalDepth = viewRayOpticalDepth + starRayOpticalDepth;

      totalRayleighAttenuationDensityFactor += exp(-opticalDepth) * viewRayStepMiddleRayleighDensityRatio;
      totalMieAttenuationDensityFactor += exp(-opticalDepth) * viewRayStepMiddleRayleighDensityRatio;
    }

    viewRayTotalRayleighDensityRatio += viewRayStepMiddleRayleighDensityRatio * 0.5;
    viewRayTotalMieDensityRatio += viewRayStepMiddleMieDensityRatio * 0.5;
  }

  vec3 chanceOfRayleighScatteringFactor = atmosphereRayleighScatteringCoefficientSurface * Scattering_getRayleighPhase(starViewAngle);
  vec3 rayleighScatteringFactor = chanceOfRayleighScatteringFactor * totalRayleighAttenuationDensityFactor;

  float chanceOfMieScatteringFactor = atmosphereMieScatteringCoefficientSurface * Scattering_getMiePhase(starViewAngle, atmosphereMieAsymmetry);
  vec3 mieScatteringFactor = chanceOfMieScatteringFactor * totalMieAttenuationDensityFactor;

  vec3 totalScatteringContribution = viewRayStepSize * (rayleighScatteringFactor + mieScatteringFactor);
  vec3 skyRadiance = starEmission * totalScatteringContribution;

  gl_FragColor = vec4(skyRadiance, 1.0);
}
