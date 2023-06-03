PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.Apps extends LM.Content
  @id: -> 'LearnMode.Intro.Tutorial.Content.Apps'

  @displayName: -> "Apps"

  @contents: -> [
    @StudyPlan
    @Drawing
    @Pico8
  ]

  @initialize()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ContentProgress content: @

  status: -> LM.Content.Status.Unlocked

  class @StudyPlan extends LM.Content
    @id: -> 'LearnMode.Intro.Tutorial.Content.Apps.StudyPlan'

    @displayName: -> "Study Plan"

    @initialize()

    constructor: ->
      super arguments...

      @progress = new LM.Content.Progress.ManualProgress
        content: @
        completed: => true
        completedRatio: => 1

    status: -> if PAA.PixelBoy.Apps.LearnMode.isAppUnlocked PAA.PixelBoy.Apps.StudyPlan.id() then LM.Content.Status.Unlocked else LM.Content.Status.Locked

  class @Drawing extends LM.Content
    @id: -> 'LearnMode.Intro.Tutorial.Content.Apps.Drawing'

    @displayName: -> "Drawing"

    @unlockInstructions: -> "Complete the Study Plan goal in the Study Plan app to be able to unlock the Drawing app."

    @initialize()

    constructor: ->
      super arguments...

      @progress = new LM.Content.Progress.ManualProgress
        content: @
        completed: => true
        completedRatio: => 1

    status: ->
      studyPlanGoal = PAA.Learning.Goal.getAdventureInstanceForId LM.Intro.Tutorial.Goals.StudyPlan.id()
      return LM.Content.Status.Unavailable unless studyPlanGoal.completed()

      if PAA.PixelBoy.Apps.LearnMode.isAppUnlocked PAA.PixelBoy.Apps.Drawing.id() then LM.Content.Status.Unlocked else LM.Content.Status.Locked

  class @Pico8 extends LM.Content
    @id: -> 'LearnMode.Intro.Tutorial.Content.Apps.Pico8'

    @displayName: -> "PICO-8"

    @unlockInstructions: -> "Complete the Pixel art software goal to be able to unlock the PICO-8 app."

    @initialize()

    constructor: ->
      super arguments...

      @progress = new LM.Content.Progress.ManualProgress
        content: @
        completed: => true
        completedRatio: => 1

    status: ->
      return unless intro = LOI.adventure.getEpisode LM.Intro
      return LM.Content.Status.Unavailable unless intro.pico8Enabled()

      if PAA.PixelBoy.Apps.LearnMode.isAppUnlocked PAA.PixelBoy.Apps.Pico8.id() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
