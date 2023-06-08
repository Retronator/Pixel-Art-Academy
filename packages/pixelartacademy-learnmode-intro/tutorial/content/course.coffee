LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.Course extends LM.Content.Course
  @id: -> 'LearnMode.Intro.Tutorial.Content.Course'

  @displayName: -> "Learn Mode tutorial"

  @learnModeDescription: -> """
    Use the Learn Mode app to track progress through the game and unlock new content.
  """

  @contents: -> [
    LM.Intro.Tutorial.Content.Apps
    LM.Intro.Tutorial.Content.Goals
    LM.Intro.Tutorial.Content.DrawingTutorials
    LM.Intro.Tutorial.Content.DrawingChallenges
    LM.Intro.Tutorial.Content.Projects
  ]

  @initialize()
