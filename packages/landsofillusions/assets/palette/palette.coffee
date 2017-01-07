LOI = LandsOfIllusions

class LandsOfIllusionsAssetsPalette extends Document
  # name: name of the palette
  # ramps: array of
  #   name: name of the ramp
  #   shades: array of
  #     r: red attribute (0.0-1.0)
  #     g: green attribute (0.0-1.0)
  #     b: blue attribute (0.0-1.0)
  @Meta
    name: 'LandsOfIllusionsAssetsPalette'

  # Enumeration of palette names provided by the system.
  @systemPaletteNames:
    atari2600: "Atari 2600"
    pico8: "PICO-8"

  # Default palette is the Atari 2600
  @defaultPaletteName: @systemPaletteNames.atari2600

  @defaultPalette: ->
    @documents.findOne name: @defaultPaletteName

  color: (rampIndex, shadeIndex) ->
    # Ramp index must match exactly.
    ramp = @ramps[rampIndex]
    return unless ramp?.shades.length

    # Shade can over/underflow and we just clamp it to last available value.
    shadeIndex = THREE.Math.clamp shadeIndex, 0, ramp.shades.length - 1
    colorData = ramp.shades[shadeIndex]

    new THREE.Color.fromObject colorData

LOI.Assets.Palette = LandsOfIllusionsAssetsPalette
