RA = Retronator.Accounts
PADB = PixelArtDatabase

PADB.Artwork.insert.method (artworkData) ->
  check artworkData, Object

  RA.authorizeAdmin()

  PADB.Artwork.documents.insert artworkData
