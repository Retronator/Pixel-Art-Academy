// LandsOfIllusions.Engine.Materials.PBRMaterial.vertex
#include <THREE>
#include <uv_pars_vertex>

attribute vec2 pixelCoordinates;

varying vec2 vPixelCoordinates;

#ifdef USE_MAP
  uniform mat3 textureMapping;
#endif

varying vec3 vFragmentPositionInWorldSpace;

void main()	{
  #include <begin_vertex>
  #include <project_vertex>

  vFragmentPositionInWorldSpace = (modelMatrix * vec4(position, 1.0)).xyz;

  vPixelCoordinates = pixelCoordinates;

  #include <LandsOfIllusions.Engine.Materials.mapTextureVertex>
}
