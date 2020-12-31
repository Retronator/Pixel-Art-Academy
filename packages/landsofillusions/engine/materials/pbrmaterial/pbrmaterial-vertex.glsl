// LandsOfIllusions.Engine.Materials.PBRMaterial.vertex
#include <THREE>
#include <uv_pars_vertex>

// Globals
uniform mat4 cameraAngleMatrix;

attribute vec2 pixelCoordinates;

varying vec2 vPixelCoordinates;
varying float vCameraAngleW;

#ifdef USE_MAP
  uniform mat3 textureMapping;
#endif

varying vec3 vFragmentPositionInWorldSpace;

void main()	{
  #include <begin_vertex>
  #include <project_vertex>

  vFragmentPositionInWorldSpace = (modelMatrix * vec4(position, 1.0)).xyz;

  // We need to linearly interpolate pixel coordinates in the picture's camera angle clip
  // space so we need to calculate the W component of the vertex in camera angle's space.
  vCameraAngleW = (cameraAngleMatrix * modelMatrix * vec4(position, 1.0)).w;
  vPixelCoordinates = pixelCoordinates * vCameraAngleW;

  #include <LandsOfIllusions.Engine.Materials.mapTextureVertex>
}
