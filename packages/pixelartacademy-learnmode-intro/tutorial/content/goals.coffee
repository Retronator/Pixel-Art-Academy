PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.Goals extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Goals'

  @displayName: -> "Study goals"

  @unlockInstructions: -> "Learn how to use to-do tasks to unlock study goals."

  @contents: -> [
    @PixelArtSoftware
    @Snake
  ]

  @initialize()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ContentProgress
      content: @
      weight: 2
      requiredUnits: "goals"
      totalUnits: "tasks"
      totalRecursive: true
  
  status: ->
    toDoTasksGoal = PAA.Learning.Goal.getAdventureInstanceForId LM.Intro.Tutorial.Goals.ToDoTasks.id()
    if toDoTasksGoal.completed() then @constructor.Status.Unlocked else @constructor.Status.Locked

  class @Snake extends LM.Content.GoalContent
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Goals.Snake'
    @goalClass = LM.Intro.Tutorial.Goals.Snake
    
    @unlockInstructions: -> "Complete the Pixel art software challenge to unlock the Snake game study goal."
    
    @initialize()
    
    status: ->
      pixelArtSoftwareGoal = PAA.Learning.Goal.getAdventureInstanceForId LM.Intro.Tutorial.Goals.PixelArtSoftware.id()
      if pixelArtSoftwareGoal.completed() then @constructor.Status.Unlocked else @constructor.Status.Locked

  class @PixelArtSoftware extends LM.Content.GoalContent
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Goals.PixelArtSoftware'
    @goalClass = LM.Intro.Tutorial.Goals.PixelArtSoftware
    @initialize()
