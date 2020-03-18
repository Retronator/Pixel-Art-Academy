// LandsOfIllusions.Engine.Skydome.Material.fragment
#include <THREE>
#include <uv_pars_fragment>
#include <map_pars_fragment>

#include <Artificial.Pyramid.OctahedronMap>

uniform float resolution;

void main() {
  // Convert texture coordinates to direction.
  float azimuthAngle = (vUv.x - 0.5) * PI2;
  float altitudeAngle = (vUv.y - 0.5) * PI;
  float radius = cos(altitudeAngle);
  vec3 direction = vec3(cos(azimuthAngle) * radius, sin(azimuthAngle) * radius, sin(altitudeAngle));

  // Sample the octahedron map sky texture.
  vec2 octahedronMapPosition = OctahedronMap_directionToPosition(direction, resolution);
  gl_FragColor = vec4(texture2D(map, octahedronMapPosition).rgb, 1);

  #include <tonemapping_fragment>
  #include <encodings_fragment>
}
