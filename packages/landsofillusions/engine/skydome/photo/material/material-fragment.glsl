// LandsOfIllusions.Engine.Skydome.Photo.Material.fragment
#include <THREE>
#include <uv_pars_fragment>
#include <map_pars_fragment>

void main() {
  gl_FragColor = vec4(texture2D(map, vUv).rgb, 1);

  #include <tonemapping_fragment>
  #include <encodings_fragment>
}
