AE = Artificial.Everywhere
LOI = LandsOfIllusions

https = require 'https'

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
  
LOI.Assets.Palette.importFromLospec.method (slug) ->
  check slug, String
  
  LOI.Authorize.player()
  
  existingPalette = LOI.Assets.Palette.documents.findOne lospecSlug: slug
  throw new AE.ArgumentException "Palette with this Lospec slug already exists." if existingPalette
  
  # On the client we wait for the server to insert the palette.
  return if Meteor.isClient
  
  # Fetch palette data from Lospec.
  try
    url = "https://lospec.com/palette-list/#{slug}.json"
    response = https.get url
    
    lospecData = JSON.parse response.content
  
  catch error
    console.error url, response, error
    throw new AE.HttpRequestException "Failed to load palette data from Lospec.", error.message
    
  palette =
    name: lospecData.name
    ramps: for color in lospecData.colors
      shades: [new THREE.Color(color).toObject()]
    lospecSlug: slug
  
  LOI.Assets.Palette.documents.insert palette
