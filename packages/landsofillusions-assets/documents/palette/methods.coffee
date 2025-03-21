RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.Palette.insert.method (palette) ->
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

  RA.authorizeAdmin()

  # Create an empty palette if no data is provided.
  palette ?= {}

  # Insert into the database.
  LOI.Assets.Palette.documents.insert palette
  
LOI.Assets.Palette.remove.method (paletteId) ->
  check paletteId, Match.DocumentId
  
  RA.authorizeAdmin()
  
  # Insert into the database.
  LOI.Assets.Palette.documents.remove paletteId
