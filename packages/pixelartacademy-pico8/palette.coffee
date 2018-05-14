LOI = LandsOfIllusions

# Add Pico-8 palette if it's not present.
if Meteor.isServer
  Document.startup ->
    return if Meteor.settings.startEmpty

    pico8PaletteName = LOI.Assets.Palette.systemPaletteNames.pico8
  
    pico8PaletteRaw =
      """
        000000	black
        1d2b53	dark_blue
        7e2553	dark_purple
        008751	dark_green
        ab5236	brown
        5f574f	dark_gray
        c2c3c7	light_gray
        fff1e8	white
        ff004d	red
        ffa300	orange
        fff024  yellow
        00e756	green
        29adff	blue
        83769c	indigo
        ff77a8	pink
        ffccaa	peach
      """

    colorLines = pico8PaletteRaw.split /\r?\n/
    # name: name of the palette
    # ramps: array of
    #   name: name of the ramp
    #   shades: array of
    #     r: red attribute (0.0-1.0)
    #     g: green attribute (0.0-1.0)
    #     b: blue attribute (0.0-1.0)
    pico8Palette =
      name: pico8PaletteName
      ramps: []

    for colorLine in colorLines
      colorAttributes = _.trim(colorLine).split /\s+/

      # Create a hue ramp with just this shade.
      pico8Palette.ramps.push
        name: colorAttributes[1].replace '_', ' '
        shades: [new THREE.Color("##{colorAttributes[0]}").toObject()]

    LOI.Assets.Palette.documents.upsert name: pico8Palette.name, pico8Palette
