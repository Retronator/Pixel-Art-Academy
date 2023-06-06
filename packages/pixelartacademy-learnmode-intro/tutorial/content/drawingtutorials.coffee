PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.DrawingTutorials extends LM.Content
  @id: -> 'LearnMode.Intro.Tutorial.Content.DrawingTutorials'

  @displayName: -> "Drawing tutorials"

  @unlockInstructions: -> "Unlock the Drawing app to get access to drawing tutorials."

  @contents: -> [
    @Basics
    @Colors
    @Helpers
  ]

  @initialize()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ContentProgress
      content: @
      units: "tutorials"
      weight: 3
      requiredUnits: "tutorials"
      totalUnits: "tutorial steps"
      totalRecursive: true

  status: -> if PAA.PixelBoy.Apps.LearnMode.isAppUnlocked PAA.PixelBoy.Apps.StudyPlan.id() then LM.Content.Status.Unlocked else LM.Content.Status.Locked

  class @Basics extends LM.Content.DrawingTutorialContent
    @id: -> 'LearnMode.Intro.Tutorial.Content.DrawingTutorials.Basics'
    @tutorialClass = PAA.Tutorials.Drawing.PixelArtTools.Basics

    @initialize()

  class @Colors extends LM.Content.DrawingTutorialContent
    @id: -> 'LearnMode.Intro.Tutorial.Content.DrawingTutorials.Colors'
    @tutorialClass = PAA.Tutorials.Drawing.PixelArtTools.Colors

    @unlockInstructions: -> "Complete the Basics tutorial to unlock the Colors tutorial."

    @initialize()

    status: ->
      return LM.Content.Status.Locked unless PAA.Tutorials.Drawing.PixelArtTools.Basics.completed()

      super arguments...

  class @Helpers extends LM.Content.DrawingTutorialContent
    @id: -> 'LearnMode.Intro.Tutorial.Content.DrawingTutorials.Helpers'
    @tutorialClass = PAA.Tutorials.Drawing.PixelArtTools.Helpers

    @unlockInstructions: -> "Complete the Basics tutorial to unlock the Helpers tutorial."

    @initialize()

    status: ->
      return LM.Content.Status.Locked unless PAA.Tutorials.Drawing.PixelArtTools.Basics.completed()

      super arguments...
