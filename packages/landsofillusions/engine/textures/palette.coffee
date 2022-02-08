AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.Engine.Textures.Palette extends THREE.DataTexture
  constructor: (palette) ->
    paletteTextureData = new Uint8Array 256 * 256 * 4
    super paletteTextureData, 256, 256, THREE.RGBAFormat

    @update palette if palette

  update: (palette) ->
    paletteTextureData = @image.data
    paletteTextureData.fill 0

    for ramp, rampIndex in palette.ramps
      for shade, shadeIndex in ramp.shades
        # Universal material is expecting colors defined in linear space.
        linearShade = AS.Color.SRGB.getNormalizedRGBForGammaRGB shade

        dataIndex = (rampIndex + shadeIndex * 256) * 4

        paletteTextureData[dataIndex] = linearShade.r * 255
        paletteTextureData[dataIndex + 1] = linearShade.g * 255
        paletteTextureData[dataIndex + 2] = linearShade.b * 255
        paletteTextureData[dataIndex + 3] = 255

    @needsUpdate = true
