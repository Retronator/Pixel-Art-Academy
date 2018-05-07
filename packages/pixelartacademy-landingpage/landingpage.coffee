PAA = PixelArtAcademy

class PAA.LandingPage
  constructor: ->
    Retronator.App.addPublicPage 'pixelart.academy/about', @constructor.Pages.About
    Retronator.App.addPublicPage 'pixelart.academy/press', @constructor.Pages.Press
    Retronator.App.addPublicPage '/help', @constructor.Pages.Help
    Retronator.App.addPublicPage 'retronator.com/smallprint', @constructor.Pages.Smallprint
