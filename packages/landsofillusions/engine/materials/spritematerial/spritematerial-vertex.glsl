// LandsOfIllusions.Engine.Materials.SpriteMaterial.fragment
#include <common>
#include <uv_pars_vertex>
#include <shadowmap_pars_vertex>

varying vec3 vViewPosition;

void main()	{
  #include <uv_vertex>
  #include <begin_vertex>
  #include <project_vertex>
  #include <worldpos_vertex>
  #include <shadowmap_vertex>

  vViewPosition = -mvPosition.xyz;
}
