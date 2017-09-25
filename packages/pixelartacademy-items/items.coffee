LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Items extends LOI.Adventure.Global
  @id: -> 'PixelArtAcademy.Items'

  @scenes: -> [
    @Bottle.Scene
    @Map.Scene
  ]

  @initialize()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-items'
    assets: Assets
