// LandsOfIllusions.Engine.RadianceState.RadianceMaterial.Out.fragment
#include <LandsOfIllusions.Engine.RadianceState.RadianceMaterial.paremetersFragment>

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

  vec3 outputRadiance = irradiance / hemisphereSolidAngle;

  gl_FragColor = vec4(outputRadiance, 1);
}
