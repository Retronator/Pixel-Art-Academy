RA = Retronator.Accounts
PADB = PixelArtDatabase

PADB.Artist.all.publish ->
  RA.authorizeAdmin()
  PADB.Artist.documents.find()
