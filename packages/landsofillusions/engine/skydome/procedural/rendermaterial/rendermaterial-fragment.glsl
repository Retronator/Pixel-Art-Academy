// LandsOfIllusions.Engine.Skydome.Procedural.RenderMaterial.fragment
#include <LandsOfIllusions.Engine.Skydome.Procedural.RenderMaterial.parametersFragment>

uniform sampler2D scatteringMap;

void main() {
  vec2 octahedronMapPosition = vec2(vUv.x, vUv.y / 2.0);
  vec3 viewDirection = normalize(OctahedronMap_positionToDirection(octahedronMapPosition));
  vec3 viewpoint = vec3(0, 0, planetRadius + 1.0);
  vec3 starRayDirection = -starDirection;
  float starViewAngle = acos(dot(viewDirection, starRayDirection));

  // Start with scattered radiance.
  vec3 radiance = texture2D(scatteringMap, vUv.xy).rgb * scatteringFactor;

  if (starViewAngle < starAngularSizeHalf) {
    // See how far the view ray reaches before it exits the atmosphere or hits the planet.
    float viewRayLengthThroughAtmosphere = getLengthThroughAtmosphere(viewpoint, viewDirection);
    float viewRayStepSize = viewRayLengthThroughAtmosphere / float(viewRaySteps);

    float viewRayTotalRayleighDensityRatio = 0.0;
    float viewRayTotalMieDensityRatio = 0.0;

    for (int viewRayStepCount = 0; viewRayStepCount < viewRaySteps; viewRayStepCount++) {
      float viewRayStepMiddleDistance = (float(viewRayStepCount) - 0.5) * viewRayStepSize;
      vec3 viewRayStepMiddle = viewpoint + viewDirection * viewRayStepMiddleDistance;
      float viewRayStepMiddleHeight = length(viewRayStepMiddle) - planetRadius;
      float viewRayStepMiddleRayleighDensityRatio = exp(-viewRayStepMiddleHeight / atmosphereRayleighScaleHeight);
      float viewRayStepMiddleMieDensityRatio = exp(-viewRayStepMiddleHeight / atmosphereMieScaleHeight);
      viewRayTotalRayleighDensityRatio += viewRayStepMiddleRayleighDensityRatio;
      viewRayTotalMieDensityRatio += viewRayStepMiddleMieDensityRatio;
    }

    vec3 viewRayRayleighScatteringCoefficient = atmosphereRayleighScatteringCoefficientSurface * viewRayTotalRayleighDensityRatio;
    float viewRayMieScatteringCoefficient = atmosphereMieScatteringCoefficientSurface * viewRayTotalMieDensityRatio;
    vec3 viewRayOpticalDepth = viewRayStepSize * (viewRayRayleighScatteringCoefficient + viewRayMieScatteringCoefficient);

    vec3 transmission = exp(-viewRayOpticalDepth);

    radiance += starEmission * transmission * starFactor;
  }

  gl_FragColor = vec4(radiance, 1);
}
