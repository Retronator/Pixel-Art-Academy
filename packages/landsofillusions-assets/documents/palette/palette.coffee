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

  closestPaletteColor: (r, g, b, backgroundColor) ->
    closestRamp = null
    closestShade = null
    smallestColorDistance = if backgroundColor then @_colorDistance backgroundColor, r, g, b else 3
    
    for ramp, rampIndex in @ramps
      for shade, shadeIndex in ramp.shades
        distance = @_colorDistance shade, r, g, b
        
        if distance < smallestColorDistance
          smallestColorDistance = distance
          closestRamp = rampIndex
          closestShade = shadeIndex

    # Return nothing if the background color was closer to any of the palette colors.
    return null unless closestRamp?

    ramp: closestRamp
    shade: closestShade
  
  _colorDistance: (color, r, g, b) ->
    Math.abs(color.r - r) + Math.abs(color.g - g) + Math.abs(color.b - b)
