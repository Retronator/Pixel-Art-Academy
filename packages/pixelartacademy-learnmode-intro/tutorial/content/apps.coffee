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

    @progress = new LM.Content.Progress.ContentProgress
      content: @
      units: "apps"

  status: -> LM.Content.Status.Unlocked

  class @StudyPlan extends LM.Content.AppContent
    @id: -> 'LearnMode.Intro.Tutorial.Content.Apps.StudyPlan'
    @appClass = PAA.PixelBoy.Apps.StudyPlan
    @initialize()

  class @Drawing extends LM.Content.AppContent
    @id: -> 'LearnMode.Intro.Tutorial.Content.Apps.Drawing'
    @appClass = PAA.PixelBoy.Apps.Drawing

    @unlockInstructions: -> "Complete the Study Plan goal to be able to unlock the Drawing app."

    @initialize()

    status: ->
      studyPlanGoal = PAA.Learning.Goal.getAdventureInstanceForId LM.Intro.Tutorial.Goals.StudyPlan.id()
      return LM.Content.Status.Unavailable unless studyPlanGoal.completed()

      super arguments...

  class @Pico8 extends LM.Content.AppContent
    @id: -> 'LearnMode.Intro.Tutorial.Content.Apps.Pico8'
    @appClass = PAA.PixelBoy.Apps.Pico8

    @unlockInstructions: -> "Complete the Pixel art software goal to be able to unlock the PICO-8 app."

    @initialize()

    status: ->
      pixelArtSoftwareGoal = PAA.Learning.Goal.getAdventureInstanceForId LM.Intro.Tutorial.Goals.PixelArtSoftware.id()
      pixelArtSoftwareGoal.completed()

      super arguments...
