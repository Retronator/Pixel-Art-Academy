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
  
  for artwork in artworks
    # See if the artwork has a document representation.
    continue unless documentRepresentation = _.find artwork.representations, (representation) -> representation.type is PADB.Artwork.RepresentationTypes.Document
    
    # Extract the type and ID.
    url = new URL Meteor.absoluteUrl documentRepresentation.url
    id = url.searchParams.get 'id'

    spriteIds.push id if _.startsWith documentRepresentation.url, LOI.Assets.Sprite.documentUrl()

  # Get all assets.
  spritesCursor = LOI.Assets.Sprite.documents.find _id: $in: spriteIds
  
  [artworksCursor, spritesCursor]
