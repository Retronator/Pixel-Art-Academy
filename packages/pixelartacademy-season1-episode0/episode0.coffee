LOI = LandsOfIllusions

class PixelArtAcademy.Season1.Episode0 extends LOI.Adventure.Episode
  @id: -> 'PixelArtAcademy.Season1.Episode0'

  @chapters: -> [
    @Chapter0
    @Chapter1
  ]

  @initialize()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-season1-episode0'
    assets: Assets
