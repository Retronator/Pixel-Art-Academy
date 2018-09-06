AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Palette extends AM.Document
  @id: -> 'LandsOfIllusions.Assets.Palette'
  # name: unique name of the palette
  # ramps: array of
  #   name: name of the ramp
  #   shades: array of
  #     r: red attribute (0.0-1.0)
  #     g: green attribute (0.0-1.0)
  #     b: blue attribute (0.0-1.0)
  # lospecSlug: the URL slug used on Lospec for this palette
  @Meta
    name: @id()

  @all: @subscription 'all'
  @forId: @subscription 'forId'
  @forName: @subscription 'forName'
  
  @insert: @method 'insert'

  # Enumeration of palette names provided by the system.
  @SystemPaletteNames:
    atari2600: "Atari 2600"
    pico8: "PICO-8"
    black: "Black"
    zxSpectrum: "ZX Spectrum"

  # Default palette is the Atari 2600
  @defaultPaletteName = @SystemPaletteNames.atari2600

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
