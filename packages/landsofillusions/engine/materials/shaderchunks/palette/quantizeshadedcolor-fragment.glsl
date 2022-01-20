// LandsOfIllusions.Engine.Materials.quantizeShadedColorFragment

if (smoothShading && colorQuantizationFactor > 0.0) {
  shadedColor = floor(shadedColor * colorQuantizationFactor + 0.5) / colorQuantizationFactor;
}
