PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.DrawingTutorials extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.DrawingTutorials'

  @displayName: -> "Drawing tutorials"

  @unlockInstructions: -> "Learn how to use to-do tasks to unlock drawing tutorials."

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
      weight: 3
      requiredUnits: "tutorials"
      totalUnits: "tutorial steps"
      totalRecursive: true
  
  status: ->
    toDoTasksGoal = PAA.Learning.Goal.getAdventureInstanceForId LM.Intro.Tutorial.Goals.ToDoTasks.id()
    if toDoTasksGoal.completed() then @constructor.Status.Unlocked else @constructor.Status.Locked

  class @Basics extends LM.Content.DrawingTutorialContent
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.DrawingTutorials.Basics'
    @tutorialClass = PAA.Tutorials.Drawing.PixelArtTools.Basics

    @initialize()

  class @Colors extends LM.Content.DrawingTutorialContent
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.DrawingTutorials.Colors'
    @tutorialClass = PAA.Tutorials.Drawing.PixelArtTools.Colors

    @unlockInstructions: -> "Complete the Basics tutorial to unlock the Colors tutorial."

    @initialize()

    status: ->
      return LM.Content.Status.Locked unless PAA.Tutorials.Drawing.PixelArtTools.Basics.completed()

      super arguments...

  class @Helpers extends LM.Content.DrawingTutorialContent
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.DrawingTutorials.Helpers'
    @tutorialClass = PAA.Tutorials.Drawing.PixelArtTools.Helpers

    @unlockInstructions: -> "Complete the Basics tutorial to unlock the Helpers tutorial."

    @initialize()

    status: ->
      return LM.Content.Status.Locked unless PAA.Tutorials.Drawing.PixelArtTools.Basics.completed()

      super arguments...
