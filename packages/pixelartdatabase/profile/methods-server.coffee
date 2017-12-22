RA = Retronator.Accounts
PADB = PixelArtDatabase

PADB.Profile.adminRefresh.method (id) ->
  check id, Match.DocumentId
  RA.authorizeAdmin()

  PADB.Profile.refresh id
