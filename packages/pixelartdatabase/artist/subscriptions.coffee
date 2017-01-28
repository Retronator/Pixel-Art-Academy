PADB = PixelArtDatabase

PADB.Artist.all.publish ->
  PADB.Artist.documents.find()
