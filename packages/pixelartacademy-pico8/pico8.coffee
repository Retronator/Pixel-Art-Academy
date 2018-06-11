PAA = PixelArtAcademy

class PAA.Pico8
  constructor: ->
    Retronator.App.addPublicPage '/pico8/:game?/:project?', @constructor.Pages.Pico8
