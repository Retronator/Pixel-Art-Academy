LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Season1.Episode0 extends LOI.Adventure.Episode
  @id: -> 'PixelArtAcademy.Season1.Episode0'

  @fullName: -> "Before it all began"

  @chapters: -> [
    @Chapter1
    @Chapter2
    @Chapter3
  ]

  @scenes: -> [
    @Map
  ]
    
  @startSection: -> @Start

  @initialize()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-season1-episode0'
    assets: Assets
