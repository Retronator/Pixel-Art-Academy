// LandsOfIllusions.Engine.Skydome.Material.vertex
#include <THREE>
#include <uv_pars_vertex>

void main() {
  #include <uv_vertex>

  // We need to flip the UVs horizontally since we're mapping the inside of the sphere.
  vUv.x = 1.0 - vUv.x;

  // Skydome is always positioned in the center of the view so strip the view matrix's translation part.
  mat4 viewRotation = modelViewMatrix;
  viewRotation[3] = vec4(0, 0, 0, 1);
  gl_Position = projectionMatrix * viewRotation * vec4(position, 1.0);
}
