// LandsOfIllusions.Engine.RadianceState.commonParametersFragment
uniform float radianceAtlasProbeLevel;
uniform float radianceAtlasProbeResolution;

vec2 directionToOctahedronMap(vec3 direction, float resolution) {
  vec3 pointOnOctahedron = direction / (abs(direction.x) + abs(direction.y) + abs(direction.z));
  vec2 hemispherePosition = vec2(
    (pointOnOctahedron.x + pointOnOctahedron.y + 1.0) * 0.5,
    (pointOnOctahedron.x - pointOnOctahedron.y + 1.0) * 0.5
  );

  // Clamp positions outside outmost pixel centers.
  float border = 0.5 / resolution;
  hemispherePosition = clamp(hemispherePosition, border, 1.0 - border);

  // Position hemisphere in top or bottom half.
  hemispherePosition.y = hemispherePosition.y * 0.5 + (direction.z < 0.0 ? 0.5 : 0.0);

  return hemispherePosition;
}

vec3 octahedronMapToDirection(vec2 octahedronMapPosition) {
  vec2 hemispherePosition = vec2(
    octahedronMapPosition.x,
    mod(octahedronMapPosition.y, 0.5) * 2.0
  );

  vec3 pointOnOctahedron = vec3(
    hemispherePosition.x + hemispherePosition.y - 1.0,
    hemispherePosition.x - hemispherePosition.y,
    0.0
  );

  pointOnOctahedron.z = 1.0 - abs(pointOnOctahedron.x) - abs(pointOnOctahedron.y);
  if (octahedronMapPosition.y >= 0.5) pointOnOctahedron.z *= -1.0;

  return pointOnOctahedron;
}

vec3 sampleRadiance(sampler2D radianceAtlas, vec2 clusterSize, vec2 probeCoordinates, vec3 direction) {
  vec2 octahedronMapPosition = directionToOctahedronMap(direction, radianceAtlasProbeResolution);

  vec2 probePosition = probeCoordinates / clusterSize;
  vec2 probeSize = 1.0 / clusterSize;

  vec2 samplePosition = probePosition + octahedronMapPosition * probeSize;

  return texture2D(radianceAtlas, samplePosition).rgb;
}
