PAA = PixelArtAcademy

class PAA.LandingPage
  constructor: ->
    Retronator.App.addPublicPage '/about', 'PixelArtAcademy.LandingPage.Pages.About'
    Retronator.App.addPublicPage '/press', 'PixelArtAcademy.LandingPage.Pages.Press'
