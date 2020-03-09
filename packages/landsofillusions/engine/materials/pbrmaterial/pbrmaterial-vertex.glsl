// LandsOfIllusions.Engine.Materials.PBRMaterial.vertex

#include <common>
#include <uv_pars_vertex>

attribute vec2 pixelCoordinates;

varying vec3 vNormal;
varying vec2 vPixelCoordinates;

#ifdef USE_MAP
uniform mat3 textureMapping;
#endif

varying vec3 vViewPosition;

void main()	{
  #include <beginnormal_vertex>
  #include <defaultnormal_vertex>
  vNormal = normalize(transformedNormal);
  vPixelCoordinates = pixelCoordinates;

  #include <begin_vertex>
  #include <project_vertex>
  #include <worldpos_vertex>

  #include <LandsOfIllusions.Engine.Materials.mapTextureVertex>

  vViewPosition = -mvPosition.xyz;
}
