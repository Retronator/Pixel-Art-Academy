LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.Course extends LM.Content.Course
  @id: -> 'LearnMode.Intro.Tutorial.Content.Course'

  @displayName: -> "Learn Mode tutorial"

  @learnModeDescription: -> """
    Learn essential pixel art tools and create art for your first game.
  """

  @contents: -> [
    LM.Intro.Tutorial.Content.Apps
    LM.Intro.Tutorial.Content.Goals
    LM.Intro.Tutorial.Content.DrawingTutorials
    LM.Intro.Tutorial.Content.DrawingChallenges
    LM.Intro.Tutorial.Content.Projects
  ]

  @initialize()
