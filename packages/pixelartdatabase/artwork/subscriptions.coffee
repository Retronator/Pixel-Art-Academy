PADB = PixelArtDatabase

PADB.Artwork.all.publish ->
  PADB.Artwork.documents.find()
