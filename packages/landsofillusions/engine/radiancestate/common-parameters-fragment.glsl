// LandsOfIllusions.Engine.RadianceState.commonParametersFragment
uniform float radianceAtlasProbeLevel;
uniform float radianceAtlasProbeResolution;

#include <Artificial.Pyramid.OctahedronMap>

vec3 sampleRadiance(sampler2D radianceAtlas, vec2 clusterSize, vec2 probeCoordinates, vec3 direction) {
  vec2 octahedronMapPosition = OctahedronMap_directionToPosition(direction, radianceAtlasProbeResolution);

  vec2 probePosition = probeCoordinates / clusterSize;
  vec2 probeSize = 1.0 / clusterSize;

  vec2 samplePosition = probePosition + octahedronMapPosition * probeSize;

  return texture2D(radianceAtlas, samplePosition).rgb;
}
