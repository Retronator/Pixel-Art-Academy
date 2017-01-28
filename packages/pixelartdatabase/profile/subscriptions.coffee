PADB = PixelArtDatabase

PADB.Profile.forUsername.publish (username) ->
  check username, String

  PADB.Profile.documents.find
    username: new RegExp username, 'i'
