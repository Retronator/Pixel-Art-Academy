PAA = PixelArtAcademy

Meteor.publish 'artworksAllArtists', ->
  PAA.Artworks.Artist.documents.find()
