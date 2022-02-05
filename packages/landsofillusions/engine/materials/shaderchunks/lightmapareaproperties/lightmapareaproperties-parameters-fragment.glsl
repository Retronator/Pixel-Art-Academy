// LandsOfIllusions.Engine.Materials.lightmapAreaPropertiesParametersFragment

varying float vLightmapAreaPropertiesIndex;
uniform sampler2D lightmapAreaProperties;

// Correlates to the LandsOfIllusions.Engine.Textures.LightmapAreaProperties constants.
const float maxLightmapAreaProperties = 4.0;
const float lightmapAreaPropertyPosition = 0.5 / maxLightmapAreaProperties;
const float lightmapAreaPropertySize = 1.5 / maxLightmapAreaProperties;
const float lightmapAreaPropertyActiveMipmapLevel = 2.5 / maxLightmapAreaProperties;

float readLightmapAreaProperty(float property) {
  return texture2D(lightmapAreaProperties, vec2(vLightmapAreaPropertiesIndex, property)).r;
}

vec2 readLightmapAreaProperty2(float property) {
  return texture2D(lightmapAreaProperties, vec2(vLightmapAreaPropertiesIndex, property)).rg;
}

vec2 readLightmapAreaProperty3(float property) {
  return texture2D(lightmapAreaProperties, vec2(vLightmapAreaPropertiesIndex, property)).rgb;
}

vec2 readLightmapAreaProperty4(float property) {
  return texture2D(lightmapAreaProperties, vec2(vLightmapAreaPropertiesIndex, property)).rgba;
}
