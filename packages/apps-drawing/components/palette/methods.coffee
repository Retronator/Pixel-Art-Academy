LOI = LandsOfIllusions

Meteor.methods
  paletteInsert: (paletteId, palette) ->
    check paletteId, Match.DocumentId
    check palette, Match.OptionalOrNull Match.ObjectIncluding
      name: Match.Optional String
      ramps: [Match.ObjectIncluding
        name: Match.Optional String
        shades: [Match.ObjectIncluding
          r: Number
          g: Number
          b: Number
        ]
      ]

    # Create an empty palette if no data is provided.
    palette ?=
      ramps: []

    # Set the desired id.
    palette._id = paletteId

    # Insert into DB.
    LOI.Assets.Palette.documents.insert palette
