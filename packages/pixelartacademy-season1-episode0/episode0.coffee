LOI = LandsOfIllusions

class PixelArtAcademy.Season1.Episode0 extends LOI.Adventure.Episode
  @id: -> 'PixelArtAcademy.Season1.Episode0'

  @fullName: -> "Before it all began"

  @chapters: -> [
    @Chapter1
    @Chapter2
    @Chapter3
  ]

  @initialize()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-season1-episode0'
    assets: Assets
