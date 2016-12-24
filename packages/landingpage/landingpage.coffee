LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.LandingPage
  @debug = false

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_landingpage'
    assets: Assets
