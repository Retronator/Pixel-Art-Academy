AE = Artificial.Everywhere
LOI = LandsOfIllusions

Meteor.methods
  spriteInsert: (spriteId, options) ->
    check spriteId, Match.DocumentId

    check options, Match.ObjectIncluding
      name: Match.OptionalOrNull String

      palette: Match.OptionalOrNull Match.ObjectIncluding
        id: Match.OptionalOrNull Match.DocumentId
        name: Match.OptionalOrNull String

      bounds: Match.OptionalOrNull Match.ObjectIncluding
        left: Number
        right: Number
        top: Number
        bottom: Number

    # Determine palette.
    if options.palette
      if options.palette._id
        paletteId = options.palette._id

      else
        paletteId = LOI.Assets.Palette.documents.findOne(name: options.palette.name)?._id

    paletteId ?= LOI.Assets.Palette.defaultPalette()?._id

    LOI.Assets.Sprite.documents.insert
      _id: spriteId
      name: options.name
      pixels: []
      palette:
        _id: paletteId
      origin:
        x: 0
        y: 0
      colorMap: {}
      bounds: options.bounds

  spriteUpdate: (spriteId, update, options) ->
    check spriteId, Match.DocumentId
    check update, Object
    check options, Match.Optional Object

    LOI.Assets.Sprite.documents.update spriteId, update, options

  spriteRemove: (spriteId) ->
    check spriteId, Match.Optional Match.DocumentId

    LOI.Assets.Sprite.documents.remove spriteId
