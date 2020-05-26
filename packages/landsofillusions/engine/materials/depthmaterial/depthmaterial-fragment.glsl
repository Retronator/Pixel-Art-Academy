// LandsOfIllusions.Engine.Materials.DepthMaterial.fragment
#include <THREE>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <packing>

#include <LandsOfIllusions.Engine.Materials.readTextureDataParametersFragment>

void main()	{
  // Discard transparent pixels for textured fragments.
  #ifdef USE_MAP
    vec2 paletteColor;
    #include <LandsOfIllusions.Engine.Materials.readTextureDataFragment>
  #endif

  gl_FragColor = packDepthToRGBA(gl_FragCoord.z);
}
