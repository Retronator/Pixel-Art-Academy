LOI = LandsOfIllusions

class LOI.Assets.Palette.Atari2600
  @hues =
    grey: 0
    yellow: 1
    orange: 2
    peach: 3
    red: 4
    magenta: 5
    purple: 6
    indigo: 7
    blue: 8
    azure: 9
    cyan: 10
    aqua: 11
    green: 12
    lime: 13
    olive: 14
    brown: 15
    
  @characterShades =
    darkest: -2
    darker: -1
    normal: 0
    lighter: 1
    lightest: 2

# Add Atari 2600 palette if it's not present.
if Meteor.isServer
  Document.startup ->
    atari2600PaletteName = LOI.Assets.Palette.systemPaletteNames.atari2600

    atari2600HueNames = (name for name of LOI.Assets.Palette.Atari2600.hues)

    atari2600PaletteRawHex = '#000000 #444400 #702800 #861800 #8a0000 #78005c #480078 #140086 #00008a #00187c #002c5c #00402c #003c00 #143800 #2c3000 #442800 #404040 #646410 #864414 #9a3418 #9e2020 #8e2074 #602092 #30209a #1c209e #1c3892 #1c4c78 #1c5c48 #205c20 #345c1c #4c501c #644818 #6c6c6c #868624 #9a5c28 #ae5030 #b23c3c #a23c8a #783ca6 #4c3cae #3840b2 #3854aa #386892 #387c64 #407c40 #507c38 #687034 #866830 #929292 #a2a234 #ae783c #c26848 #c25858 #b2589e #8e58ba #6858c2 #505cc2 #5070be #5086ae #509e82 #5c9e5c #6c9a50 #868e4c #a28644 #b2b2b2 #baba40 #be8e4c #d2825c #d27070 #c270b2 #a270ce #7c70d2 #6874d2 #688ace #689ec2 #68b696 #74b674 #86b668 #9eaa64 #ba9e58 #cacaca #d2d250 #cea25c #e29670 #e28a8a #d286c2 #b686de #968ae2 #7c8ee2 #7c9ede #7cb6d6 #7cd2ae #8ed28e #9ece7c #b6c278 #d2b66c #dedede #eaea5c #deb668 #eeaa82 #eea2a2 #de9ed2 #c69eee #aaa2ee #92a6ee #92b6ee #92ceea #92e6c2 #a6e6a6 #b6e692 #ced68a #eace7c #eeeeee #fefe68 #eace7c #febe96 #feb6b6 #eeb2e2 #d6b2fe #beb6fe #a6bafe #a6cafe #a6e2fe #a6fed6 #bafeba #cafea6 #e2ee9e #fee28e'
    colorsHex = atari2600PaletteRawHex.split ' '

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
    atari2600palette =
      name: atari2600PaletteName
      ramps: []

    for rampIndex in [0..15]
      ramp =
        name: atari2600HueNames[rampIndex]
        shades: []

      atari2600palette.ramps[rampIndex] = ramp

      # Pad with black color.
      ramp.shades[0] = new THREE.Color(0).toObject()

      for shadeIndex in [0..7]
        ramp.shades[shadeIndex + 1] = new THREE.Color(colorsHex[shadeIndex * 16 + rampIndex]).toObject()

      # Pad with white color.
      ramp.shades[9] = new THREE.Color(0xeeeeee).toObject()

    LOI.Assets.Palette.documents.upsert name: atari2600palette.name, atari2600palette
