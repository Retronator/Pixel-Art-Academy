// LandsOfIllusions.Engine.RadianceState.Probe.OctahedronMapMaterial.fragment
precision highp float;
#include <LandsOfIllusions.Engine.RadianceState.commonParametersFragment>

uniform samplerCube probeCube;

varying vec2 vUv;

void main() {
  vec3 direction = OctahedronMap_positionToDirection(vUv);
  vec3 radiance = textureCube(probeCube, direction).rgb;
  gl_FragColor = vec4(radiance, 1);
}
