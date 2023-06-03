LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.Course extends LM.Content.Course
  @id: -> 'LearnMode.Intro.Tutorial.Content.Course'

  @displayName: -> "Tutorial"

  @contents: -> [
    LM.Intro.Tutorial.Content.Apps
    LM.Intro.Tutorial.Content.Goals
  ]

  @initialize()
