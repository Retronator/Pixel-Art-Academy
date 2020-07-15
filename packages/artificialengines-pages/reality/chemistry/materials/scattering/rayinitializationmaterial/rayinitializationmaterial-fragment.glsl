// Artificial.Reality.Pages.Chemistry.Materials.Scattering.RayInitializationMaterial.fragment
precision highp float;
precision highp int;

#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.uniforms>

uniform sampler2D map;

varying vec2 vUv;

void main() {
  float rayColumn = vUv.x * raysCount;
  bool leftColumn = mod(rayColumn, 1.0) < 0.5;
  bool topVertex = vUv.y < 0.5;

  if (leftColumn == topVertex) {
    vec4 rayData = texture2D(map, vUv);

    if (leftColumn) {
      // Store position of vertex 0 and set transmission to 1.
      gl_FragColor = vec4(rayData.x, rayData.y, 1, 1);

    } else {
      // Store direction of segment 1 and set transmission to 1.
      gl_FragColor = vec4(rayData.z, rayData.w, 1, 1);

    }
  } else {
    gl_FragColor = vec4(0);
  }
}
