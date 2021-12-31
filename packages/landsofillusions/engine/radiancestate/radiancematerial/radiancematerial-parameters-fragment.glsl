// LandsOfIllusions.Engine.RadianceState.RadianceMaterial.parametersFragment
#extension GL_EXT_shader_texture_lod : enable
precision highp float;

#include <THREE>
#include <LandsOfIllusions.Engine.RadianceState.commonParametersFragment>

uniform sampler2D probeOctahedronMap;
uniform float probeOctahedronMapMaxLevel;
uniform float probeOctahedronMapResolution;

varying vec2 vUv;

vec3 sampleProbe(vec2 octahedronMapPosition, float level) {
  // Mipmap levels are reversed (0 for biggest, max level for 1x1).
  float mipmapLevel = probeOctahedronMapMaxLevel - level;

  // Since mipmap generation averages instead of sums the pixels, we
  // need to amplify the irradince 4x at each mipmap generation level.
  float mipmapFactor = pow(4.0, mipmapLevel);

  return texture2DLodEXT(probeOctahedronMap, octahedronMapPosition, mipmapLevel).rgb * mipmapFactor;
}

vec3 sampleProbe(vec3 direction, float level) {
  float resolution = pow(2.0, level);
  vec2 octahedronMapPosition = OctahedronMap_directionToPosition(direction, resolution);
  return sampleProbe(octahedronMapPosition, level);
}
