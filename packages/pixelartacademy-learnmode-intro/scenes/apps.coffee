LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Apps extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Apps'

  @location: -> PAA.PixelBoy.Apps

  @initialize()

  things: -> [
    PAA.PixelBoy.Apps.StudyPlan
    PAA.PixelBoy.Apps.Drawing if PAA.PixelBoy.Apps.StudyPlan.hasGoal LM.Intro.Tutorial.Goals.PixelArtSoftware
  ]
