// LandsOfIllusions.Engine.IlluminationState.IlluminationMaterial.fragment

#extension GL_EXT_shader_texture_lod : enable
precision highp float;

#include <THREE>
#include <LandsOfIllusions.Engine.IlluminationState.commonParametersFragment>

uniform sampler2D probeOctahedronMap;
uniform float probeOctahedronMapMaxLevel;
uniform float probeOctahedronMapResolution;

varying vec2 vUv;

void main() {
  // Sample the probe at 1x1 mipmap level to get the full sum of illumination at this location.
  float mipmapLevel = probeOctahedronMapMaxLevel;

  // Since mipmap generation averages instead of sums the pixels, we
  // need to amplify the irradince 4x at each mipmap generation level.
  float mipmapFactor = pow(4.0, mipmapLevel);

  vec3 irradiance = texture2DLodEXT(probeOctahedronMap, vec2(0.5, 0.25), mipmapLevel).rgb * mipmapFactor;

  gl_FragColor = vec4(irradiance, 1.0);
}
