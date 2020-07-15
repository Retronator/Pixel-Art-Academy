// Artificial.Reality.Pages.Chemistry.Materials.Scattering.RayMarchingMaterial.vertex

#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.uniforms>

uniform int updateLevel;

attribute vec3 position;
attribute vec2 uv;

varying vec2 vUv;

void main() {
  // Only update the current segment level.
  float pixelHeight = 1.0 / verticesPerRay;

  float verticesToUpdate = pow(2.0, float(updateLevel));
  float heightToUpdate = pixelHeight * verticesToUpdate;

  vUv = vec2(uv.x, heightToUpdate * (1.0 + uv.y));
  gl_Position = vec4(position.x, -1.0 + vUv.y * 2.0, 0, 1);
}
