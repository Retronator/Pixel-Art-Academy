RA = Retronator.Accounts
PADB = PixelArtDatabase

PADB.Artwork.all.publish ->
  RA.authorizeAdmin()
  PADB.Artwork.documents.find()

PADB.Artwork.forUrl.publish (url) ->
  check url, String

  PADB.Artwork.forUrl.query url

PADB.Artwork.forArtistName.publish (name) ->
  check name, PADB.Artist.namePattern

  artistIds = PADB.Artist.forName.query(name).map (artist) -> artist._id

  PADB.Artwork.documents.find
    'authors._id': $in: artistIds

PADB.Artwork.forArtistPseudonym.publish (pseudonym) ->
  check pseudonym, String

  artistIds = PADB.Artist.documents.find({pseudonym}).map (artist) -> artist._id

  PADB.Artwork.documents.find
    'authors._id': $in: artistIds
