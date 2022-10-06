LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

{URL} = require 'url'

PAA.PixelBoy.Apps.Drawing.Portfolio.artworksWithAssets.publish (characterId, artworkIds) ->
  check characterId, Match.DocumentId

  # Get all artwork documents.
  artworksCursor = PADB.Artwork.documents.find _id: $in: artworkIds
  artworks = artworksCursor.fetch()
  
  # Get all asset IDs.
  spriteIds = []
  bitmapIds = []

  for artwork in artworks
    # See if the artwork has a document representation.
    continue unless documentRepresentation = _.find artwork.representations, (representation) -> representation.type is PADB.Artwork.RepresentationTypes.Document
    
    # Extract the type and ID.
    url = new URL Meteor.absoluteUrl documentRepresentation.url
    id = url.searchParams.get 'id'

    spriteIds.push id if _.startsWith documentRepresentation.url, LOI.Assets.Sprite.documentUrl()
    bitmapIds.push id if _.startsWith documentRepresentation.url, LOI.Assets.Bitmap.documentUrl()

  # Get all the assets.
  spritesCursor = LOI.Assets.Sprite.documents.find _id: $in: spriteIds

  bitmapsCursor = LOI.Assets.Bitmap.documents.find _id: $in: bitmapIds,
    fields:
      versioned: true
  
  [artworksCursor, spritesCursor, bitmapsCursor]
