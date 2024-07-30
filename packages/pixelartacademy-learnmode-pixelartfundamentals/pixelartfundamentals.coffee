LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals extends LOI.Adventure.Episode
  # unlocked: boolean whether this episode's content is instantly available
  # pinballUnlocked: boolean whether the pinball project is instantly available
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals'

  @fullName: -> "Pixel art fundamentals"

  @chapters: -> [
    @Fundamentals
  ]

  @scenes: -> [
    @Apps
    @Systems
  ]
  
  @startSection: -> @Start
  
  @initialize()
  
  @pinballEnabled: ->
    # Allow cheating.
    return true if LM.PixelArtFundamentals.state 'pinballUnlocked'
    
    PAA.Learning.Task.getAdventureInstanceForId(LM.PixelArtFundamentals.Fundamentals.Goals.Jaggies.SmoothCurves.id())?.completed()
  
  meetsAccessRequirement: ->
    # Pixel art fundamentals are not available in the demo.
    false

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-learnmode-pixelartfundamentals'
    assets: Assets
