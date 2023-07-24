PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.Goals extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Goals'

  @displayName: -> "Study goals"

  @unlockInstructions: -> "Learning goals are unlocked from the start."

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

  status: -> LM.Content.Status.Unlocked

  class @Snake extends LM.Content.GoalContent
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Goals.Snake'
    @goalClass = LM.Intro.Tutorial.Goals.Snake
    @initialize()

  class @PixelArtSoftware extends LM.Content.GoalContent
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Goals.PixelArtSoftware'
    @goalClass = LM.Intro.Tutorial.Goals.PixelArtSoftware
    @initialize()
