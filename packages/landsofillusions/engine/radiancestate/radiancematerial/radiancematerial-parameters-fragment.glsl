// LandsOfIllusions.Engine.RadianceState.RadianceMaterial.paremetersFragment
precision highp float;
#extension GL_EXT_shader_texture_lod : enable

#include <THREE>
#include <LandsOfIllusions.Engine.RadianceState.commonParametersFragment>

uniform sampler2D probeOctahedronMap;
uniform float probeOctahedronMapMaxLevel;
uniform float probeOctahedronMapResolution;

varying vec2 vUv;

vec3 sampleProbe(vec2 octahedronMapPosition, float level) {
  return texture2DLodEXT(probeOctahedronMap, octahedronMapPosition, probeOctahedronMapMaxLevel - level).rgb;
}

vec3 sampleProbe(vec3 direction, float level) {
  float resolution = pow(2.0, level);
  vec2 octahedronMapPosition = OctahedronMap_directionToPosition(direction, resolution);
  return sampleProbe(octahedronMapPosition ,level);
}
