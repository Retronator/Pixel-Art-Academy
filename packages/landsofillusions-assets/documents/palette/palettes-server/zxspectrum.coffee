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
    name: LOI.Assets.Palette.SystemPaletteNames.ZXSpectrum
    lospecSlug: 'zx-spectrum'
    ramps: [
      name: 'black', shades: [r: 0, g: 0, b: 0]
    ,
      name: 'blue', shades: [r: 0, g: 0, b: 1]
    ,
      name: 'red', shades: [r: 1, g: 0, b: 0]
    ,
      name: 'magenta', shades: [r: 1, g: 0, b: 1]
    ,
      name: 'green', shades: [r: 0, g: 1, b: 0]
    ,
      name: 'cyan', shades: [r: 0, g: 1, b: 1]
    ,
      name: 'yellow', shades: [r: 1, g: 1, b: 0]
    ,
      name: 'white', shades: [r: 1, g: 1, b: 1]
    ]

  for ramp in palette.ramps
    darkShade = _.clone ramp.shades[0]
    darkShade[attribute] = value * 192 / 255 for attribute, value of darkShade
    ramp.shades.unshift darkShade
  
  LOI.Assets.Palette.addIfNeeded palette
