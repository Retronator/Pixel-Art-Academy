// LandsOfIllusions.Engine.Skydome.RenderMaterial.fragment
precision highp float;

#include <Artificial.Pyramid.OctahedronMap>

uniform vec3 sunDirection;

varying vec2 vUv;

const float sunAngularSizeHalf = 0.004625;

void main() {
  vec2 octahedronMapPosition = vUv;
  vec3 direction = normalize(OctahedronMap_positionToDirection(octahedronMapPosition));

  float sunViewAngle = acos(dot(direction, -sunDirection));

  gl_FragColor = vec4(0.05, 0.1, 0.15, 1);
  gl_FragColor = vec4(0, 0, 0, 1);

  if (sunViewAngle < sunAngularSizeHalf) {
    gl_FragColor = vec4(1);
  }

  if (direction.z < 0.0) {
    gl_FragColor = vec4(0, 0, 0, 1);
  }
}
