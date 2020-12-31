// Artificial.Reality.Pages.Chemistry.Materials.Scattering.RaySplittingMaterial.vertex

#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.uniforms>

uniform int updateLevel;

attribute vec3 position;
attribute vec2 uv;

varying vec2 vUv;

void main() {
  // Only update the current and previous segment level.
  float pixelHeight = 1.0 / verticesPerRay;

  float verticesToUpdateThisLevel = pow(2.0, float(updateLevel));
  float verticesToUpdatePreviousLevel = max(1.0, verticesToUpdateThisLevel / 2.0);

  float updateStartY = pixelHeight * (verticesToUpdateThisLevel - verticesToUpdatePreviousLevel);
  float heightToUpdate = pixelHeight * (verticesToUpdateThisLevel + verticesToUpdatePreviousLevel);

  vUv = vec2(uv.x, updateStartY + uv.y * heightToUpdate);
  gl_Position = vec4(position.x, -1.0 + vUv.y * 2.0, 0, 1);
}
