// LandsOfIllusions.Engine.Materials.PreprocessingMaterial.vertex
#include <common>
#include <uv_pars_vertex>

#ifdef USE_MAP
uniform mat3 textureMapping;
#endif

void main()	{
  #include <begin_vertex>
  #include <project_vertex>
  #include <worldpos_vertex>

  #include <LandsOfIllusions.Engine.Materials.mapTextureVertex>
}
