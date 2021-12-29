// LandsOfIllusions.Engine.IlluminationState.commonParametersFragment

uniform sampler2D illuminationAtlas;
uniform sampler2D probeMapAtlas;
uniform vec2 layerAtlasSize;

vec3 sampleIllumination(vec2 layerPosition, vec2 pixelPosition) {
  vec2 probePosition = layerPosition + pixelPosition;
  vec2 samplePosition = (probePosition + vec2(0.5)) / layerAtlasSize;

  return texture2D(illuminationAtlas, samplePosition).rgb;
}
