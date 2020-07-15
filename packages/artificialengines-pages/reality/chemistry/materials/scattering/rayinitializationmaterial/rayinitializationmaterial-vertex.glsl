// Artificial.Reality.Pages.Chemistry.Materials.Scattering.RayInitializationMaterial.vertex

#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.uniforms>

attribute vec3 position;
attribute vec2 uv;

varying vec2 vUv;

void main() {
  // Only update the top 2 pixels.
  float pixelClipSpaceHeight = 2.0 / verticesPerRay;
  float positionY = -1.0 + (position.y / 2.0 + 0.5) * 2.0 * pixelClipSpaceHeight;
  gl_Position = vec4(position.x, positionY, 0, 1);
  vUv = uv;
}
