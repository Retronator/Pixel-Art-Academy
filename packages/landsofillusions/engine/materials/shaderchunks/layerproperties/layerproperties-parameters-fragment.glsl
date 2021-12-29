// LandsOfIllusions.Engine.Materials.layerPropertiesParametersFragment

varying float vLayerPropertiesIndex;
uniform sampler2D layerProperties;

// Correlates to the LandsOfIllusions.Engine.Textures.LayerProperties constants.
const float maxLayerProperties = 4.0;
const float layerPropertyAtlasPositionX = 0.5 / maxLayerProperties;
const float layerPropertyAtlasPositionY = 1.5 / maxLayerProperties;
const float layerPropertyWidth = 2.5 / maxLayerProperties;
const float layerPropertyHeight = 3.5 / maxLayerProperties;

float readLayerProperty(float property) {
  return texture2D(layerProperties, vec2(vLayerPropertiesIndex, property)).a;
}
