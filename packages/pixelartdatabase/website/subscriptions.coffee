RA = Retronator.Accounts
PADB = PixelArtDatabase

PADB.Website.all.publish ->
  RA.authorizeAdmin()
  
  PADB.Website.documents.find()
