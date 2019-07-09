LOI = LandsOfIllusions

LOI.Engine.Materials.ShaderChunks.readSpriteData = """
  vec2 spriteUv = vUv;

  if (!powerOf2Texture) {
    // Wrap UV coordinates manually since we want to wrap a non-power-of-2 texture.
    spriteUv -= floor(vUv);
  }

  float lodBias = -0.3;

  // Read palette color from main map.
  vec2 paletteColor = texture2D(map, spriteUv, lodBias).xy;
  paletteColor = (paletteColor * 255.0 + 0.5) / 256.0;

  // Read normal from normal map.
  vec3 spriteNormal = texture2D(normalMap, spriteUv, lodBias).xyz;
  spriteNormal = (spriteNormal - 0.5) * 2.0;
"""
