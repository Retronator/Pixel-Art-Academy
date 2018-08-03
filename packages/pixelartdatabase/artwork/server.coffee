AM = Artificial.Mummification
AE = Artificial.Everywhere
PADB = PixelArtDatabase

PADB.Artwork.create = (documentData) ->
  # We try to find a matching image or representation of this artwork.
  artworkQuery =
    $or: []

  if documentData.image?.url
    artworkQuery.$or.push
      'image.url': documentData.image?.url

  if documentData.representations?
    for representation in documentData.representations
      artworkQuery.$or.push
        'representations.url': representation.url

  artworks = PADB.Artwork.documents.fetch artworkQuery

  # TODO: If we have multiple artworks that match the name, we'll need to resolve this in another way.
  if artworks.length > 1
    console.error "Multiple artworks were found with given URLs.", documentData.image, documentData.representations
    return

  if artworks.length is 1
    artwork = artworks[0]
    artworkId = artwork._id

    # Override old with new data. We have to manually merge the representations array.
    documentData.representations = _.unionWith artwork.representations, documentData.representations, EJSON.equals if documentData.representations
    
    _.extend artwork, documentData

    # Update the artwork in the database.
    PADB.Artwork.documents.update artworkId, artwork

  else
    # This is a new artwork, we can simply insert it.
    artworkId = PADB.Artwork.documents.insert documentData

  # Return the new document.
  PADB.Artist.documents.findOne artworkId
