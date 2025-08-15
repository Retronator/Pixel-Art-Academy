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
  # category: the category under which the palette appears in the selector or null if not selectable
  # lospecSlug: the URL slug used on Lospec for this palette
  # lospecAuthor: the author of the palette as provided by Lospec
  @Meta
    name: @id()
  
  @enableDatabaseContent()
  
  @Categories =
    Basic: "Basic"
    Monoramp: "Monoramp"
    System: "System"
    Modern: "Modern"
  
  @databaseContentInformationFields =
    name: 1
    lospecSlug: 1
    category: 1

  @all = @subscription 'all'
  @allLospec = @subscription 'allLospec'
  @allCategorized = @subscription 'allCategorized'
  @forId = @subscription 'forId'
  @forIds = @subscription 'forIds'
  @forName = @subscription 'forName'
  
  @insert = @method 'insert'
  @update = @method 'update'
  @remove = @method 'remove'

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
    
  closestPaletteColor: (color, backgroundColor, secondClosestColor) ->
    LOI.Assets.ColorHelper.closestPaletteColor @, color, backgroundColor, secondClosestColor
  
  closestPaletteColorFromRGB: (r, g, b, backgroundColor) ->
    LOI.Assets.ColorHelper.closestPaletteColorFromRGB @, r, g, b, backgroundColor
