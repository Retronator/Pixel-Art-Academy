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

LOI.Assets.Palette.update.method (paletteId, paletteUpdate) ->
  check paletteId, Match.DocumentId
  check paletteUpdate, Match.ObjectIncluding
    category: Match.OptionalOrNull Match.Where (value) -> LOI.Assets.Palette.Categories[value]
  
  RA.authorizeAdmin()
  
  update =
    $set:
      lastEditTime: new Date()
  
  if paletteUpdate.category?
    if paletteUpdate.category
      update.$set.category = paletteUpdate.category
      
    else
      update.$unset ?= {}
      update.$unset.category = true
  
  LOI.Assets.Palette.documents.update paletteId, update
  
LOI.Assets.Palette.remove.method (paletteId) ->
  check paletteId, Match.DocumentId
  
  RA.authorizeAdmin()
  
  LOI.Assets.Palette.documents.remove paletteId
