LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Season1.Episode1 extends LOI.Adventure.Episode
  @id: -> 'PixelArtAcademy.Season1.Episode1'

  @fullName: -> "Back to school"

  @chapters: -> []
    
  @scenes: -> [
    @Inventory
  ]
    
  @startSection: -> @Start

  # Whole Episode 1 happens in the present.
  @timelineId: -> PAA.TimelineIds.Present

  @initialize()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-season1-episode1'
    assets: Assets
