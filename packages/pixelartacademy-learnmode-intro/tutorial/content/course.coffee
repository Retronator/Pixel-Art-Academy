LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.Course extends LM.Content.Course
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Course'

  @displayName: -> "Pixel art tools"

  @description: -> """
    Learn essential pixel art tools and create art for your first game.
  """
  
  @tags: -> [
    LM.Content.Tags.Free
  ]

  @contents: -> [
    LM.Intro.Tutorial.Content.Goals
    LM.Intro.Tutorial.Content.DrawingTutorials
    LM.Intro.Tutorial.Content.DrawingChallenges
    LM.Intro.Tutorial.Content.Projects
    LM.Intro.Tutorial.Content.Apps
  ]

  @initialize()
