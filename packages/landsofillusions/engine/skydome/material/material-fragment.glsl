// LandsOfIllusions.Engine.Skydome.Material.fragment
#include <THREE>
#include <uv_pars_fragment>
#include <map_pars_fragment>

#include <Artificial.Pyramid.OctahedronMap>

uniform float resolution;

void main() {
  // Bottom hemisphere doesn't have a sky color since it's in planet shadow.
  if (vUv.y < 0.5) {
    gl_FragColor = vec4(0, 0, 0, 1);
    return;
  }

  // Convert texture coordinates to direction.
  float azimuthAngle = (vUv.x - 0.5) * PI2;
  float altitudeAngle = (vUv.y - 0.5) * PI;
  float radius = cos(altitudeAngle);
  vec3 direction = vec3(cos(azimuthAngle) * radius, sin(azimuthAngle) * radius, sin(altitudeAngle));

  // Sample the octahedron map sky texture.
  vec2 octahedronMapPosition = OctahedronMap_directionToPosition(direction, resolution);
  vec2 hemispherePosition = vec2(octahedronMapPosition.x, octahedronMapPosition.y * 2.0);
  gl_FragColor = vec4(texture2D(map, hemispherePosition).rgb, 1);

  #include <tonemapping_fragment>
  #include <encodings_fragment>
}
