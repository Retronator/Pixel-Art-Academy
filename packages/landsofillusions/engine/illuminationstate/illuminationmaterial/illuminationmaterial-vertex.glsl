// LandsOfIllusions.Engine.IlluminationState.IlluminationMaterial.vertex
uniform mat4 modelViewProjectionMatrix;

attribute vec3 position;
attribute vec2 uv;

varying vec2 vUv;

void main() {
  gl_Position = modelViewProjectionMatrix * vec4(position, 1.0);
  vUv = uv;
}
