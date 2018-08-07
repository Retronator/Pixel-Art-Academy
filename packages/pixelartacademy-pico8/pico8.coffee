PAA = PixelArtAcademy

class PAA.Pico8
  constructor: ->
    Retronator.App.addPublicPage 'pixelart.academy/pico8/:gameSlug?/:projectId?', @constructor.Pages.Pico8
