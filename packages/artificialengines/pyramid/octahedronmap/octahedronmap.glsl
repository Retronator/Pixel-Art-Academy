// Artificial.Pyramid.OctahedronMap

// Converts a direction to a position on the octahedron map. The resolution of the octahedron map can be specified in
// which case the position on the hemisphere will be clamped to the centers of the pixels. This is to prevent bleed
// across hemispheres when sampling with linear interpolation.
vec2 OctahedronMap_directionToPosition(vec3 direction, float resolution) {
  vec3 pointOnOctahedron = direction / (abs(direction.x) + abs(direction.y) + abs(direction.z));
  vec2 hemispherePosition = vec2(
    (pointOnOctahedron.x + pointOnOctahedron.y + 1.0) * 0.5,
    (pointOnOctahedron.x - pointOnOctahedron.y + 1.0) * 0.5
  );

  if (resolution > 0.0) {
    // Clamp positions outside outmost pixel centers.
    float border = 0.5 / resolution;
    hemispherePosition = clamp(hemispherePosition, border, 1.0 - border);
  }

  // Position hemisphere in top or bottom half.
  return vec2(
    hemispherePosition.x,
    hemispherePosition.y * 0.5 + (direction.z < 0.0 ? 0.5 : 0.0)
  );
}

vec2 OctahedronMap_directionToPosition(vec3 direction) {
  return OctahedronMap_directionToPosition(direction, 0.0);
}

// Converts a position on an octahedron map to a point on the octahedron.
// You can use this directly to sample a cubemap without the need for normalization.
vec3 OctahedronMap_positionToPointOnOctahedron(vec2 octahedronMapPosition) {
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

// Converts a position on an octahedron map to a direction.
vec3 OctahedronMap_positionToDirection(vec2 octahedronMapPosition) {
  return normalize(OctahedronMap_positionToPointOnOctahedron(octahedronMapPosition));
}
