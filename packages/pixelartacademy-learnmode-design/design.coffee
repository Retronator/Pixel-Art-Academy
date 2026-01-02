LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Design extends LOI.Adventure.Episode
  # unlocked: boolean whether this episode's content is instantly available
  # invasionUnlocked: boolean whether the invasion project is instantly available
  @id: -> 'PixelArtAcademy.LearnMode.Design'

  @fullName: -> "Design"

  @chapters: -> [
    @Fundamentals
  ]

  @startSection: -> @Start
  
  @initialize()
  
  @invasionEnabled: ->
    # Allow cheating.
    return true if LM.Design.state 'invasionUnlocked'
    
    return false unless PAA.PixelPad.Apps.StudyPlan.hasGoal LM.Design.Fundamentals.Goals.Invasion
    
    LM.Design.Fundamentals.Goals.ShapeLanguage.completed()
  
if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-learnmode-design'
    assets: Assets
