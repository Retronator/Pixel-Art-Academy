LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals extends LOI.Adventure.Episode
  # unlocked: boolean whether this episode's content is instantly available
  # pinballUnlocked: boolean whether the pinball project is instantly available
  # drawQuicklyUnlocked: boolean whether the Draw Quickly game is instantly available
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
  
  @pixeltoshEnabled: ->
    # Allow cheating.
    return true if @pinballEnabled() or @drawQuicklyEnabled()
    
    PAA.Tutorials.Drawing.ElementsOfArt.Line.completed()
  
  @pinballEnabled: ->
    # Allow cheating.
    return true if LM.PixelArtFundamentals.state 'pinballUnlocked'
    
    LM.PixelArtFundamentals.Fundamentals.Goals.Jaggies.SmoothCurves.completed()
    
  @drawQuicklyEnabled: ->
    # Allow cheating.
    return true if LM.PixelArtFundamentals.state 'drawQuicklyUnlocked'
    
    PAA.Tutorials.Drawing.Simplification.completed()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-learnmode-pixelartfundamentals'
    assets: Assets
