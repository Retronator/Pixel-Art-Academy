LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Intro extends LOI.Adventure.Episode
  @id: -> 'PixelArtAcademy.LearnMode.Intro'

  @fullName: -> "Learn Mode introduction"

  @chapters: -> [
    @Tutorial
  ]

  @scenes: -> [
    @PixelBoy
    @Apps
    @Editors
    @ChallengesDrawing
    @TutorialsDrawing
    @Pico8Cartridges
  ]
  
  @startSection: -> @Start
  
  @initialize()

  pico8Enabled: ->
    tutorial = _.find @chapters, (chapter) => chapter instanceof LM.Intro.Tutorial
    pixelArtSoftwareGoal = _.find tutorial.goals, (goal) => goal instanceof LM.Intro.Tutorial.Goals.PixelArtSoftware
    pixelArtSoftwareGoal.completed() and PAA.PixelBoy.Apps.StudyPlan.hasGoal LM.Intro.Tutorial.Goals.Snake

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-learnmode-intro'
    assets: Assets
