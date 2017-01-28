RA = Retronator.Accounts
PADB = PixelArtDatabase

PADB.Artist.insert.method (artistData) ->
  check artistData, Object

  RA.authorizeAdmin()

  PADB.Artist.documents.insert artistData
