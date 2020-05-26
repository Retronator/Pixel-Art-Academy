// LandsOfIllusions.Engine.Materials.quantizeShadedColorFragment

if (smoothShading && smoothShadingQuantizationFactor > 0.0) {
  shadedColor = floor(shadedColor * smoothShadingQuantizationFactor + 0.5) / smoothShadingQuantizationFactor;
}
