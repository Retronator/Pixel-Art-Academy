// LandsOfIllusions.Engine.Materials.lightmapAreaPropertiesParametersFragment

varying float vLightmapAreaPropertiesIndex;
uniform sampler2D lightmapAreaProperties;

// Correlates to the LandsOfIllusions.Engine.Textures.LightmapAreaProperties constants.
const float maxLightmapAreaProperties = 4.0;
const float lightmapAreaPropertyPositionX = 0.5 / maxLightmapAreaProperties;
const float lightmapAreaPropertyPositionY = 1.5 / maxLightmapAreaProperties;
const float lightmapAreaPropertySize = 2.5 / maxLightmapAreaProperties;
const float lightmapAreaPropertyActiveMipmapLevel = 3.5 / maxLightmapAreaProperties;

float readLightmapAreaProperty(float property) {
  return texture2D(lightmapAreaProperties, vec2(vLightmapAreaPropertiesIndex, property)).a;
}
