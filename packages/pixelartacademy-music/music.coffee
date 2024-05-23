AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Music

if Meteor.isServer
  # Export all tape documents.
  AM.DatabaseContent.addToExport ->
    PAA.Music.Tape.documents.fetch()
