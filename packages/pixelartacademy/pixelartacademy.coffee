class PixelArtAcademy
  @ContentSetIDs:
    AdventureMode: 'PixelArtAcademy.AdventureMode'
    LearnMode: 'PixelArtAcademy.LearnMode'
    LearnModeDemo: 'PixelArtAcademy.LearnModeDemo'

  constructor: ->
    PixelArtAcademy.LearnMode.App.addPublicPage '/pixelartacademy/image-classification', @constructor.Pages.ImageClassification

if Meteor.isClient
  window.PixelArtAcademy = PixelArtAcademy
  window.PAA = PixelArtAcademy
