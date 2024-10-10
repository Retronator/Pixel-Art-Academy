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
  
  @enableDatabaseContent()
  
  @databaseContentInformationFields =
    name: 1
    lospecSlug: 1

  @all = @subscription 'all'
  @allLospec = @subscription 'allLospec'
  @forId = @subscription 'forId'
  @forIds = @subscription 'forIds'
  @forName = @subscription 'forName'
  
  @insert = @method 'insert'

  # Enumeration of palette names provided by the system.
  @SystemPaletteNames:
    PixelArtAcademy: "Pixel Art Academy"
    Pico8: "PICO-8"
    Black: "Black"
    ZXSpectrum: "ZX Spectrum"
    Macintosh: "Macintosh"

  # Default palette is the modified Atari 2600.
  @defaultPaletteName = @SystemPaletteNames.PixelArtAcademy

  @imageUrl = "/landsofillusions/assets/palette.png"

  @defaultPalette: ->
    return @_defaultPalette if @_defaultPalette

    @_defaultPalette = @documents.findOne name: @defaultPaletteName
    
    @_defaultPalette

  color: (rampIndex, shadeIndex) ->
    # Ramp index must match exactly.
    ramp = @ramps[rampIndex]
    return unless ramp?.shades.length

    # Shade can over/underflow and we just clamp it to last available value.
    shadeIndex = THREE.MathUtils.clamp shadeIndex, 0, ramp.shades.length - 1
    colorData = ramp.shades[shadeIndex]

    THREE.Color.fromObject colorData

  exactPaletteColor: (color) ->
    LOI.Assets.ColorHelper.exactPaletteColor @, color
    
  closestPaletteColor: (color, backgroundColor) ->
    LOI.Assets.ColorHelper.closestPaletteColor @, color, backgroundColor
  
  closestPaletteColorFromRGB: (r, g, b, backgroundColor) ->
    LOI.Assets.ColorHelper.closestPaletteColorFromRGB @, r, g, b, backgroundColor
    
  _colorDistance: (color, r, g, b) ->
    Math.abs(color.r - r) + Math.abs(color.g - g) + Math.abs(color.b - b)
