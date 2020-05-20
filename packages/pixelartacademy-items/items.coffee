LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Items extends LOI.Adventure.Global
  @id: -> 'PixelArtAcademy.Items'

  @scenes: -> [
    @Bottle.Scene
    @StillLifeItems.Scene
    @StillLifeItems.Container.Scene
  ]

  @initialize()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-items'
    assets: Assets
