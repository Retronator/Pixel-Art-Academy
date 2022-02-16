// LandsOfIllusions.Engine.Lightmap.UpdateMaterial.vertex
uniform mat4 modelViewProjectionMatrix;

uniform sampler2D probeOctahedronMap;
uniform float probeOctahedronMapMaxLevel;

in vec3 position;

out vec3 irradiance;

void main() {
  gl_Position = modelViewProjectionMatrix * vec4(position, 1.0);

  // Sample the probe at 1x1 mipmap level to get the full sum of irradiance at this location.
  float mipmapLevel = probeOctahedronMapMaxLevel;

  // Since mipmap generation averages instead of sums the pixels, we
  // need to amplify the irradince 4x at each mipmap generation level.
  float mipmapFactor = pow(4.0, mipmapLevel);

  irradiance = textureLod(probeOctahedronMap, vec2(0.5, 0.25), mipmapLevel).rgb * mipmapFactor;
}
