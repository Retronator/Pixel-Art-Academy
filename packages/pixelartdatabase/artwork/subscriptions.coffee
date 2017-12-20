RA = Retronator.Accounts
PADB = PixelArtDatabase

PADB.Artwork.all.publish ->
  RA.authorizeAdmin()
  PADB.Artwork.documents.find()
