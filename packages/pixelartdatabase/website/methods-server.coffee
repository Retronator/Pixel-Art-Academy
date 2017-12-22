RA = Retronator.Accounts
PADB = PixelArtDatabase

PADB.Website.insert.method (initialData) ->
  check initialData, Match.OptionalOrNull Object
  RA.authorizeAdmin()

  initialData ?= {}

  PADB.Website.documents.insert initialData

PADB.Website.update.method (id, modifier) ->
  check id, Match.DocumentId
  check modifier, Object
  RA.authorizeAdmin()

  PADB.Website.documents.update id, modifier
