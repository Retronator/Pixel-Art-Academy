// Artificial.Reality.Pages.Chemistry.Materials.Scattering.RayMarchingMaterial.fragment
precision highp float;
precision highp int;

#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.uniforms>

const int maxMarchingSteps = 100;
const float minStepDistance = 1.0;

uniform sampler2D rayScatteringDataTexture;
uniform sampler2D surfaceSDFTexture;
uniform sampler2D rayPropertiesTexture;
uniform int updateLevel;

varying vec2 vUv;

void main() {
  float rayColumn = vUv.x * raysCount;
  int rayIndex = int(rayColumn);

  float vertexRow = vUv.y * verticesPerRay;
  int vertexIndex = int(vertexRow);

  bool leftColumn = mod(rayColumn, 1.0) < 0.5;

  if (leftColumn) {
    // Move from previous position to segment direction.
    int parentVertexIndex = vertexIndex / 2;
    float parentVertexV = (float(parentVertexIndex) + 0.5) / verticesPerRay;
    vec2 parentPosition = texture2D(rayScatteringDataTexture, vec2(vUv.x, parentVertexV)).rg;

    float segmentDirectionU = (rayColumn + 0.5) / raysCount;
    vec4 segmentData = texture2D(rayScatteringDataTexture, vec2(segmentDirectionU, vUv.y));
    vec2 segmentDirection = segmentData.rg;

    // Make sure the segment is alive.
    if (segmentData.a < 0.5) {
      // There's nothing to march.
      gl_FragColor = vec4(0.0);
      return;
    }

    // Calculate if we're trying to go into or out of the surface (1 = moving in, -1 = moving out).
    float signedDistance = texture2D(surfaceSDFTexture, parentPosition / canvasSize).a;
    bool parentOutside = signedDistance > 0.0;
    bool refractedSegment = mod(float(vertexIndex), 2.0) > 0.5;
    bool segmentOutside = parentOutside == refractedSegment;

    float rayGradientDirection = segmentOutside ? 1.0 : -1.0;

    vec2 currentPosition;
    float distance = max(abs(signedDistance), minStepDistance);
    bool surfaceHit = false;

    for (int step = 0; step < maxMarchingSteps; step++) {
      // See how far from the surface we are at this step.
      currentPosition = parentPosition + segmentDirection * distance;

      // See if we've run out of bounds.
      if (currentPosition.x < 0.0 || currentPosition.y < 0.0 || currentPosition.x > canvasSize.x || currentPosition.y > canvasSize.y) {
        break;
      }

      float remainingSignedDistance = texture2D(surfaceSDFTexture, currentPosition / canvasSize).a;

      if (remainingSignedDistance * rayGradientDirection <= 0.0) {
        // We've hit the surface.
        surfaceHit = true;
        break;
      }

      // We need to keep going.
      distance += max(abs(remainingSignedDistance), minStepDistance);
    }

    float segmentStartTransmission = segmentData.b;
    float segmentEndTransmission = segmentStartTransmission;

    bool vertexAlive = surfaceHit && segmentEndTransmission >= minTransmission ;
    gl_FragColor = vec4(currentPosition, segmentEndTransmission, vertexAlive ? 1.0 : 0.0);

  } else {
    // Copy data.
    gl_FragColor = texture2D(rayScatteringDataTexture, vUv);
  }
}
