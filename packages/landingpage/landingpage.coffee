LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.LandingPage
  @debug = false

  constructor: ->
    Retronator.Accounts.addPublicPage '/about', 'PixelArtAcademy.LandingPage.Pages.About'

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_landingpage'
    assets: Assets
