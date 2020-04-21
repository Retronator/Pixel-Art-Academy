// LandsOfIllusions.Engine.Skydome.RenderMaterial.Scattering.fragment
#include <LandsOfIllusions.Engine.Skydome.RenderMaterial.parametersFragment>

#include <Artificial.Reality.Optics.Scattering>

const int starRaySteps = 32;

void main() {
  vec2 octahedronMapPosition = vec2(vUv.x, vUv.y / 2.0);
  vec3 viewDirection = normalize(OctahedronMap_positionToDirection(octahedronMapPosition));
  vec3 viewpoint = vec3(0, 0, planetRadius + 1.0);
  vec3 starRayDirection = -starDirection;
  float starViewAngle = acos(dot(viewDirection, starRayDirection));

  vec3 totalTransmission;
  vec3 scatteringContribution;

  // See how far the view ray reaches before it exits the atmosphere or hits the planet.
  float viewRayLengthThroughAtmosphere = getLengthThroughAtmosphere(viewpoint, viewDirection);
  float viewRayStepSize = viewRayLengthThroughAtmosphere / float(viewRaySteps);

  float viewRayTotalDensityRatio = 0.0;

  for (int viewRayStepCount = 0; viewRayStepCount < viewRaySteps; viewRayStepCount++) {
    float viewRayStepMiddleDistance = (float(viewRayStepCount) - 0.5) * viewRayStepSize;
    vec3 viewRayStepMiddle = viewpoint + viewDirection * viewRayStepMiddleDistance;
    float viewRayStepMiddleHeight = length(viewRayStepMiddle) - planetRadius;
    float viewRayStepMiddleDensityRatio = exp(-viewRayStepMiddleHeight / atmosphereScaleHeight);
    viewRayTotalDensityRatio += viewRayStepMiddleDensityRatio / 2.0;

    // Calculate the density ratio along the star ray, if we can see the star.
    if (!intersectsPlanet(viewRayStepMiddle, starRayDirection)) {
      float starRayLengthThroughAtmosphere = getLengthThroughAtmosphere(viewRayStepMiddle, starRayDirection);
      float starRayStepSize = starRayLengthThroughAtmosphere / float(starRaySteps);

      float starRayTotalDensityRatio = 0.0;

      for (int starRayStepCount = 0; starRayStepCount < starRaySteps; starRayStepCount++) {
        float starRayStepMiddleDistance = (float(starRayStepCount) - 0.5) * starRayStepSize;
        vec3 starRayStepMiddle = viewRayStepMiddle + starRayDirection * starRayStepMiddleDistance;
        float starRayStepMiddleHeight = length(starRayStepMiddle) - planetRadius;
        float starRayStepMiddleDensityRatio = exp(-starRayStepMiddleHeight / atmosphereScaleHeight);
        starRayTotalDensityRatio += starRayStepMiddleDensityRatio;
      }

      float densityRatioFactor = viewRayTotalDensityRatio * viewRayStepSize + starRayTotalDensityRatio * starRayStepSize;
      vec3 rayOpticalDepth = atmosphereRayleighCrossSection * atmosphereMolecularNumberDensitySurface * densityRatioFactor;
      scatteringContribution += exp(-rayOpticalDepth) * viewRayStepMiddleDensityRatio;
    }

    viewRayTotalDensityRatio += viewRayStepMiddleDensityRatio / 2.0;
  }

  vec3 chanceOfScatteringFactor = atmosphereRayleighCrossSection * atmosphereMolecularNumberDensitySurface * Scattering_getRayleighPhaseFunction(starViewAngle);
  totalTransmission += scatteringContribution * chanceOfScatteringFactor * viewRayStepSize;

  vec3 skyRadiance = starEmission * totalTransmission;

  gl_FragColor = vec4(skyRadiance, 1);
}
