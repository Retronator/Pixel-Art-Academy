PAA = PixelArtAcademy

Meteor.publish 'artworksAllArtworks', ->
  PAA.Artworks.Artwork.documents.find()
