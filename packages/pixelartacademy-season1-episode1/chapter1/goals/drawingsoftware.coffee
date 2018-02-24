PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.DrawingSoftware extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.DrawingSoftware'

  @displayName: -> "Drawing software"

  Goal = @

  class @ChooseSoftware extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.DrawingSoftware.ChooseSoftware'
  
    @directive: -> "Choose drawing software"
  
    @instructions: -> """
      With the Drawing app on PixelBoy, choose digital drawing (or painting) software you want to use to complete drawing assignments.
    """

    @interests: -> ['drawing software']

    @initialize()

  @tasks: -> [
    @ChooseSoftware
  ]

  @finalTasks: -> [
    @ChooseSoftware
  ]

  @initialize()
