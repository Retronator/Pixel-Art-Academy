LOI = LandsOfIllusions

Document.startup ->
  return if Meteor.settings.startEmpty

  # name: name of the palette
  # ramps: array of
  #   name: name of the ramp
  #   shades: array of
  #     r: red attribute (0.0-1.0)
  #     g: green attribute (0.0-1.0)
  #     b: blue attribute (0.0-1.0)
  palette =
    name: LOI.Assets.Palette.SystemPaletteNames.black
    ramps: [
      name: 'black'
      shades: [r: 0, g: 0, b: 0]
    ]

  LOI.Assets.Palette.documents.upsert name: palette.name, palette
