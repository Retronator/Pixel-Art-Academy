AM = Artificial.Mummification
PAA = PixelArtAcademy

class PAA.Pico8
  constructor: ->
    Retronator.App.addPublicPage 'pixelart.academy/pico8/:gameSlug?/:projectId?', @constructor.Pages.Pico8

if Meteor.isServer
  # Export all game documents.
  AM.DatabaseContent.addToExport ->
    PAA.Pico8.Game.documents.fetch()
