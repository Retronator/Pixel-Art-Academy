LOI = LandsOfIllusions

LOI.Engine.Materials.ShaderChunks.applyPreprocessingFragment = """
  // Apply preprocessing info. The parameters are:
  // r: tint ramp
  // g: tint shade
  vec2 normalizedCoordinates = gl_FragCoord.xy / renderSize;
  vec4 preprocessingInfo = texture2D(preprocessingMap, normalizedCoordinates);

  // Tint the color if needed.
  if (preprocessingInfo.r < 1.0) {
    paletteColor.r = (preprocessingInfo.r * 255.0 + 0.5) / 256.0;
  }
"""
