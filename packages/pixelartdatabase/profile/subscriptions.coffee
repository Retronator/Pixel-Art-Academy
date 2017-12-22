RA = Retronator.Accounts
PADB = PixelArtDatabase

PADB.Profile.all.publish ->
  RA.authorizeAdmin()
  PADB.Profile.documents.find()

PADB.Profile.forUsername.publish (username) ->
  check username, String

  PADB.Profile.documents.find
    username: new RegExp username, 'i'
