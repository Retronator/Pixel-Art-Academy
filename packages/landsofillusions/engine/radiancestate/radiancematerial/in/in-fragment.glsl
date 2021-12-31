// LandsOfIllusions.Engine.RadianceState.RadianceMaterial.In.fragment
#include <LandsOfIllusions.Engine.RadianceState.RadianceMaterial.parametersFragment>

void main() {
  gl_FragColor = vec4(sampleProbe(vUv, radianceAtlasProbeLevel), 1);
}
