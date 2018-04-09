LOI = LandsOfIllusions
PAA = PixelArtAcademy
RS = Retronator.Store

class PAA.Season1.Episode1 extends LOI.Adventure.Episode
  @id: -> 'PixelArtAcademy.Season1.Episode1'

  @fullName: -> "Back to school"

  @chapters: -> [
    @Chapter1
  ]

  @scenes: -> [
    @Inventory
    @ChinaBasinPark
  ]
    
  @startSection: -> @Start

  # Whole Episode 1 happens in the present.
  @timelineId: -> LOI.TimelineIds.Present

  @accessRequirement: -> RS.Items.CatalogKeys.PixelArtAcademy.AlphaAccess
  
  @initialize()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-season1-episode1'
    assets: Assets
