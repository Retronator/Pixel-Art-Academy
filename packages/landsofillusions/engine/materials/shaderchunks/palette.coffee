LOI = LandsOfIllusions

LOI.Engine.Materials.ShaderChunks.setPaletteColorFromUniformsFragment = """
  paletteColor = (vec2(ramp, shade) + 0.5) / 256.0;
"""

LOI.Engine.Materials.ShaderChunks.readSourceColorFromPaletteFragment = """
  vec3 sourceColor = texture2D(palette, paletteColor).rgb;
"""
