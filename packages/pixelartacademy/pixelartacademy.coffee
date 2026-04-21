class PixelArtAcademy
  @ContentSetIDs:
    AdventureMode: 'PixelArtAcademy.AdventureMode'
    LearnMode: 'PixelArtAcademy.LearnMode'
    LearnModeDemo: 'PixelArtAcademy.LearnModeDemo'

  constructor: ->
    PixelArtAcademy.LearnMode.App.addPublicPage '/pixelartacademy/image-classification', @constructor.Pages.ImageClassification
    PixelArtAcademy.LearnMode.App.addPublicPage '/pixelartacademy/pixel-image-classification', @constructor.Pages.PixelImageClassification

if Meteor.isClient
  window.PixelArtAcademy = PixelArtAcademy
  window.PAA = PixelArtAcademy
