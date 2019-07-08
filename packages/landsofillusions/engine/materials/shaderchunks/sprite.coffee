LOI = LandsOfIllusions

LOI.Engine.Materials.ShaderChunks.readSpriteData = """
  // Wrap UV coordinates manually since we want to use non-power-of-2 textures.
  vec2 spriteUv = vUv - floor(vUv);

  // Read palette color from main map.
  vec2 paletteColor = texture2D(map, spriteUv).xy;
  paletteColor = (paletteColor * 255.0 + 0.5) / 256.0;

  // Read normal from normal map.
  vec3 spriteNormal = texture2D(normalMap, spriteUv).xyz;
  spriteNormal = (spriteNormal - 0.5) * 2.0;
"""
