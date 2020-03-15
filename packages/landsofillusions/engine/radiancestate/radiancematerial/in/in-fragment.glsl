// LandsOfIllusions.Engine.RadianceState.RadianceMaterial.In.fragment
#include <LandsOfIllusions.Engine.RadianceState.RadianceMaterial.paremetersFragment>

void main() {
  gl_FragColor = vec4(sampleProbe(vUv, radianceAtlasProbeLevel), 1);
}
