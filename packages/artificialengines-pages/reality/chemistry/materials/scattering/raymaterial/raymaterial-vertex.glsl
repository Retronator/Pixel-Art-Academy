// Artificial.Reality.Pages.Chemistry.Materials.Scattering.RayMaterial.vertex

#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.uniforms>

uniform float pixelUnitSize;
uniform sampler2D rayScatteringDataTexture;
uniform bool schematicView;

attribute float rayId;
attribute float segmentId;
attribute float segmentDistance;

varying float vRayId;
varying vec3 vSchematicColor;
varying float vSegmentDistance;
varying float vTransmissionStart;
varying float vTransmissionEnd;

void main() {
  // Get vertex position.
  float vertexId = segmentId;

  if (segmentDistance < 0.5) {
    vertexId = floor(segmentId / 2.0);
  }

  float vertexU = (float(rayId) + 0.25) / raysCount;
  float vertexV = (vertexId + 0.5) / verticesPerRay;

  float segmentU = vertexU + 0.5 / raysCount;
  float segmentV = (segmentId + 0.5) / verticesPerRay;

  vec4 segmentData = texture2D(rayScatteringDataTexture, vec2(segmentU, segmentV));

  // Make sure the segment is alive.
  if (segmentData.a < 0.5) {
    gl_Position = vec4(0.0);
    vRayId = 0.0;
    vSegmentDistance = 0.0;
    vTransmissionStart = 0.0;
    vTransmissionEnd = 0.0;
    return;
  }

  vec4 vertexData = texture2D(rayScatteringDataTexture, vec2(vertexU, vertexV));
  vec4 endVertexData = texture2D(rayScatteringDataTexture, vec2(vertexU, segmentV));

  vec2 positionCanvas = vertexData.rg;
  vec2 positionClipSpace = positionCanvas / canvasSize * 2.0;
  gl_Position = vec4(-1.0 + positionClipSpace, 0.0, 1.0);

  vRayId = rayId;
  vSegmentDistance = segmentDistance;
  vTransmissionStart = segmentData.b;
  vTransmissionEnd = endVertexData.b;

  if (schematicView) {
    if (segmentId < 1.5) {
      vSchematicColor = vec3(0.9, 0.9, 0.1);

    } else {
      vSchematicColor = vec3(0.1, 0.9, 0.9);
    }
  }
}
