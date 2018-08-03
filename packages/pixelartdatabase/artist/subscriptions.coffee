RA = Retronator.Accounts
PADB = PixelArtDatabase

PADB.Artist.all.publish ->
  RA.authorizeAdmin()
  PADB.Artist.documents.find()

PADB.Artist.forName.publish (name) ->
  check name, PADB.Artist.namePattern

  PADB.Artist.forName.query name

PADB.Artist.forPseudonym.publish (pseudonym) ->
  check pseudonym, String

  PADB.Artist.documents.find {pseudonym}
