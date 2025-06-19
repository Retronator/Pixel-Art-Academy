LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.Content.Course extends LM.Content.Course
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Course'

  @displayName: -> "Design fundamentals"

  @description: -> """
    Learn the main concepts and principles of design to intentionally shape your creations.
  """
  
  @tags: -> [
    LM.Content.Tags.BaseGame
    LM.Content.Tags.WIP
  ]

  @contents: -> [
    LM.Design.Fundamentals.Content.Goals
    LM.Design.Fundamentals.Content.DrawingTutorials
    LM.Design.Fundamentals.Content.Projects
  ]

  @initialize()
