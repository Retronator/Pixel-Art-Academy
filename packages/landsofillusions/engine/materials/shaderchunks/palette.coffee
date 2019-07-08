LOI = LandsOfIllusions

LOI.Engine.Materials.ShaderChunks.readSourceColorFromPalette = """
  vec3 sourceColor = texture2D(palette, paletteColor).rgb;
"""
