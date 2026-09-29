PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.Apps extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Apps'

  @displayName: -> "Apps"
  
  @unlockInstructions: -> "Learn how to use to-do tasks to unlock apps."

  @contents: -> [
    @Drawing
    @StudyPlan
    @Pico8
  ]

  @initialize()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ContentProgress
      content: @
      units: "apps"
  
  status: ->
    toDoTasksGoal = PAA.Learning.Goal.getAdventureInstanceForId LM.Intro.Tutorial.Goals.ToDoTasks.id()
    if toDoTasksGoal.completed() then @constructor.Status.Unlocked else @constructor.Status.Locked

  class @Drawing extends LM.Content.AppContent
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Apps.Drawing'
    @appClass = PAA.PixelPad.Apps.Drawing

    @initialize()

    status: -> if LM.Intro.Tutorial.Goals.ToDoTasks.completed() then LM.Content.Status.Unlocked else @constructor.Status.Locked

  class @StudyPlan extends LM.Content.AppContent
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Apps.StudyPlan'
    @appClass = PAA.PixelPad.Apps.StudyPlan
    
    @initialize()
    
    status: -> if LM.Intro.Tutorial.Goals.PixelArtSoftware.Basics.completed() then @constructor.Status.Unlocked else @constructor.Status.Locked
    
  class @Pico8 extends LM.Content.AppContent
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Apps.Pico8'
    @appClass = PAA.PixelPad.Apps.Pico8

    @unlockInstructions: -> "Complete the Pixel art software challenge to unlock the PICO-8 app."

    @initialize()

    status: -> if LM.Intro.Tutorial.Goals.PixelArtSoftware.completed() then @constructor.Status.Unlocked else @constructor.Status.Locked
