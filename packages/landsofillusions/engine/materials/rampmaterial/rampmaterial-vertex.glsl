// LandsOfIllusions.Engine.Materials.RampMaterial.vertex
#include <THREE>
#include <shadowmap_pars_vertex>
#include <uv_pars_vertex>

varying vec3 vNormal;

#ifdef USE_MAP
  uniform mat3 textureMapping;
#endif

varying vec3 vViewPosition;

void main()	{
  #include <beginnormal_vertex>
  #include <defaultnormal_vertex>
  vNormal = normalize(transformedNormal);

  #include <begin_vertex>
	#include <project_vertex>
  #include <worldpos_vertex>
	#include <shadowmap_vertex>

  #include <LandsOfIllusions.Engine.Materials.mapTextureVertex>

  vViewPosition = -mvPosition.xyz;
}
