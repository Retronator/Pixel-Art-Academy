PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.Apps extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Apps'

  @displayName: -> "Apps"
  
  @unlockInstructions: -> "Learn how to use to-do tasks to unlock apps."

  @contents: -> [
    @Drawing
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

    status: -> LM.Content.Status.Unlocked

  class @Pico8 extends LM.Content.AppContent
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Apps.Pico8'
    @appClass = PAA.PixelPad.Apps.Pico8

    @unlockInstructions: -> "Complete the Pixel art software challenge to unlock the PICO-8 app."

    @initialize()

    status: ->
      pixelArtSoftwareGoal = PAA.Learning.Goal.getAdventureInstanceForId LM.Intro.Tutorial.Goals.PixelArtSoftware.id()
      if pixelArtSoftwareGoal.completed() then @constructor.Status.Unlocked else @constructor.Status.Locked