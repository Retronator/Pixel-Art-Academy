// LandsOfIllusions.Engine.Materials.applyPreprocessingFragment

// Apply preprocessing info. The parameters are:
// r: tint ramp
// g: tint shade
vec2 normalizedCoordinates = gl_FragCoord.xy / renderSize;
vec4 preprocessingInfo = texture2D(preprocessingMap, normalizedCoordinates);

// Tint the color if needed. Note that Ramp is offset by 1 so that 0 means no tinting.
if (preprocessingInfo.r > 0.0) {
  paletteColor.r = (preprocessingInfo.r * 255.0 - 0.5) / 256.0;
}
