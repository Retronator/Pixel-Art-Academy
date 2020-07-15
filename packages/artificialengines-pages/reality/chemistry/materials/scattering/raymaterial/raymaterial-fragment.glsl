// Artificial.Reality.Pages.Chemistry.Materials.Scattering.RayMaterial.fragment
precision highp float;

#include <Artificial.Spectrum.Color.hslToRGB>
#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.uniforms>

uniform sampler2D rayPropertiesTexture;
uniform bool schematicView;

varying float vRayId;
varying vec3 vSchematicColor;
varying float vSegmentDistance;
varying float vTransmissionStart;
varying float vTransmissionEnd;

void main() {
  float transmission = max(0.0, mix(vTransmissionStart, vTransmissionEnd, vSegmentDistance));
  if (transmission == 0.0) discard;

  vec3 rayColor;

  if (schematicView) {
    rayColor = vSchematicColor;

  } else {
    rayColor = texture2D(rayPropertiesTexture, vec2((vRayId + 0.25) / raysCount, 0.5)).rgb;
  }

  gl_FragColor = vec4(rayColor, transmission);
}
