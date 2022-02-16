// LandsOfIllusions.Engine.Lightmap.Probe.OctahedronMapMaterial.fragment
precision highp float;

#include <THREE>
#include <Artificial.Pyramid.OctahedronMap>

uniform samplerCube probeCube;
uniform float sampleSolidAngle;

varying vec2 vUv;

void main() {
  vec3 direction = OctahedronMap_positionToDirection(vUv);
  float cosAngleOfIncidence = direction.z; // = [0, 0, 1] ⋅ direction

  vec3 radiance = textureCube(probeCube, direction).rgb;
  vec3 irradiance = radiance * sampleSolidAngle * cosAngleOfIncidence;
  gl_FragColor = vec4(irradiance, 1);
}
