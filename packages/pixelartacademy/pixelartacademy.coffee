class PixelArtAcademy
  @ContentSetIDs:
    AdventureMode: 'PixelArtAcademy.AdventureMode'
    LearnMode: 'PixelArtAcademy.LearnMode'
    LearnModeDemo: 'PixelArtAcademy.LearnModeDemo'

if Meteor.isClient
  window.PixelArtAcademy = PixelArtAcademy
  window.PAA = PixelArtAcademy
