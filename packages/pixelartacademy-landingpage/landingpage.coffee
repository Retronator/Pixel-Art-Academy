PAA = PixelArtAcademy

class PAA.LandingPage
  constructor: ->
    Retronator.App.addPublicPage '/about', @constructor.Pages.About
    Retronator.App.addPublicPage '/press', @constructor.Pages.Press
    Retronator.App.addPublicPage '/smallprint', @constructor.Pages.Smallprint
