RA = Retronator.Accounts
PADB = PixelArtDatabase

PADB.Artwork.all.publish ->
  RA.authorizeAdmin()
  PADB.Artwork.documents.find()

PADB.Artwork.forUrl.publish (url) ->
  check url, String

  PADB.Artwork.forUrl.query url
