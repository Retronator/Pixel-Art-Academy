LOI = LandsOfIllusions

Document.startup ->
  return if Meteor.settings.startEmpty

  third = 1 / 3
  twoThirds = 2 / 3

  # name: name of the palette
  # ramps: array of
  #   name: name of the ramp
  #   shades: array of
  #     r: red attribute (0.0-1.0)
  #     g: green attribute (0.0-1.0)
  #     b: blue attribute (0.0-1.0)
  palette =
    name: LOI.Assets.Palette.SystemPaletteNames.cga
    lospecSlug: 'color-graphics-adapter'
    ramps: [
      name: 'black', shades: [r: 0, g: 0, b: 0]
    ,
      name: 'blue', shades: [r: 0, g: 0, b: twoThirds]
    ,
      name: 'green', shades: [r: 0, g: twoThirds, b: 0]
    ,
      name: 'cyan', shades: [r: 0, g: twoThirds, b: twoThirds]
    ,
      name: 'red', shades: [r: twoThirds, g: 0, b: 0]
    ,
      name: 'magenta', shades: [r: twoThirds, g: 0, b: twoThirds]
    ,
      name: 'brown', shades: [r: twoThirds, g: third, b: 0]
    ,
      name: 'light gray', shades: [r: twoThirds, g: twoThirds, b: twoThirds]
    ]

  for ramp in palette.ramps
    lightShade = _.clone ramp.shades[0]

    for attribute, value of lightShade
      lightShade[attribute] = if value then 1 else third

    ramp.shades.push lightShade

  LOI.Assets.Palette.documents.upsert name: palette.name, palette
