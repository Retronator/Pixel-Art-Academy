LOI = LandsOfIllusions

class PixelArtAcademy.Season1.Episode1 extends LOI.Adventure.Episode
  @id: -> 'PixelArtAcademy.Season1.Episode1'

  @fullName: -> "Back to school"

  @chapters: -> []
    
  @startSection: -> @Start

  @initialize()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-season1-episode1'
    assets: Assets
