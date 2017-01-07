PAA = PixelArtAcademy

class PAA.LandingPage
  constructor: ->
    Retronator.Accounts.addPublicPage '/about', 'PixelArtAcademy.LandingPage.Pages.About'
    Retronator.Accounts.addPublicPage '/press', 'PixelArtAcademy.LandingPage.Pages.Press'
