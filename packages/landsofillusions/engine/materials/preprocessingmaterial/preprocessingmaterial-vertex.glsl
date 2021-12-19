// LandsOfIllusions.Engine.Materials.PreprocessingMaterial.vertex
#include <THREE>
#include <uv_pars_vertex>

#ifdef USE_MAP
uniform mat3 textureMapping;
#endif

#include <LandsOfIllusions.Engine.Materials.materialPropertiesParametersVertex>

void main()	{
  #include <begin_vertex>
  #include <project_vertex>
  #include <worldpos_vertex>

  #include <LandsOfIllusions.Engine.Materials.mapTextureVertex>
  #include <LandsOfIllusions.Engine.Materials.materialPropertiesVertex>
}
