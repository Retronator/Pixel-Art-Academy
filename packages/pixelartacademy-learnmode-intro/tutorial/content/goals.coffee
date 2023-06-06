PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.Goals extends LM.Content
  @id: -> 'LearnMode.Intro.Tutorial.Content.Goals'

  @displayName: -> "Study goals"

  @unlockInstructions: -> "Unlock the Study Plan app to get access to learning goals."

  @contents: -> [
    @StudyPlan
    @PixelArtSoftware
    @Snake
    @Tutorial
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

  status: -> if PAA.PixelBoy.Apps.LearnMode.isAppUnlocked PAA.PixelBoy.Apps.StudyPlan.id() then LM.Content.Status.Unlocked else LM.Content.Status.Locked

  class @Tutorial extends LM.Content.GoalContent
    @id: -> 'LearnMode.Intro.Tutorial.Content.Goals.Tutorial'
    @goalClass = LM.Intro.Tutorial.Goals.Tutorial
    @initialize()

  class @StudyPlan extends LM.Content.GoalContent
    @id: -> 'LearnMode.Intro.Tutorial.Content.Goals.StudyPlan'
    @goalClass = LM.Intro.Tutorial.Goals.StudyPlan
    @initialize()

  class @Snake extends LM.Content.GoalContent
    @id: -> 'LearnMode.Intro.Tutorial.Content.Goals.Snake'
    @goalClass = LM.Intro.Tutorial.Goals.Snake
    @initialize()

  class @PixelArtSoftware extends LM.Content.GoalContent
    @id: -> 'LearnMode.Intro.Tutorial.Content.Goals.PixelArtSoftware'
    @goalClass = LM.Intro.Tutorial.Goals.PixelArtSoftware
    @initialize()
