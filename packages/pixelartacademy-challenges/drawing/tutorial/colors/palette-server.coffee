LOI = LandsOfIllusions
PAA = PixelArtAcademy

Document.startup ->
  return if Meteor.settings.startEmpty

  pacManPaletteRaw = """
    0,0,0
    255,0,0
    222,151,81
    255,184,255
    0,255,255
    71,184,255
    255,184,81
    255,255,0
    33,33,255
    0,255,0
    71,184,174
    255,184,174
    222,222,255
  """

  colorLines = pacManPaletteRaw.split /\r?\n/

  # Create a palette with this format:
  #
  # name: name of the palette
  # ramps: array of
  #   name: name of the ramp
  #   shades: array of
  #     r: red attribute (0.0-1.0)
  #     g: green attribute (0.0-1.0)
  #     b: blue attribute (0.0-1.0)
  #
  pacManPalette =
    name: PAA.Challenges.Drawing.Tutorial.Colors.pacManPaletteName
    ramps: []

  for colorLine in colorLines
    # Create a hue ramp with just this shade.
    pacManPalette.ramps.push
      shades: [new THREE.Color("rgb(#{colorLine})").toObject()]

  LOI.Assets.Palette.documents.upsert name: pacManPalette.name, pacManPalette
