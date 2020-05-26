// LandsOfIllusions.Engine.Skydome.Material.fragment
#include <THREE>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <dithering_pars_fragment>

#include <Artificial.Pyramid.OctahedronMap>

uniform float resolution;

void main() {
  // Convert texture coordinates to direction.
  float azimuthAngle = (vUv.x - 0.5) * PI2;
  float altitudeAngle = (vUv.y - 0.5) * PI;
  float radius = cos(altitudeAngle);
  vec3 direction = vec3(cos(azimuthAngle) * radius, sin(azimuthAngle) * radius, sin(altitudeAngle));

  // Bottom hemisphere should fade out the edge color to prevent bleed.
  float fadeMultiplier = 1.0;

  if (vUv.y < 0.5) {
    direction.z = 0.0;
    fadeMultiplier = (vUv.y - 0.49) / 0.01;

    if (fadeMultiplier <= 0.0) {
      gl_FragColor = vec4(0, 0, 0, 1);
      return;
    }
  }

  // Sample the octahedron map sky texture.
  vec2 octahedronMapPosition = OctahedronMap_directionToPosition(direction, resolution);
  vec2 hemispherePosition = vec2(octahedronMapPosition.x, octahedronMapPosition.y * 2.0);
  gl_FragColor = vec4(texture2D(map, hemispherePosition).rgb * fadeMultiplier, 1);

  #include <tonemapping_fragment>
  #include <encodings_fragment>
  #include <dithering_fragment>
}
