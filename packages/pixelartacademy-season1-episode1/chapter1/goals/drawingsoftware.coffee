PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.DrawingSoftware extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.DrawingSoftware'

  @displayName: -> "Drawing software"

  @chapter: -> C1

  Goal = @

  class @ChooseSoftware extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.DrawingSoftware.ChooseSoftware'
    @goal: -> Goal

    @directive: -> "Choose drawing software"
  
    @instructions: -> """
      With the Drawing app on PixelBoy, choose the digital drawing (or painting) software you want to use to complete
      drawing assignments.
    """

    @initialize()

  class @Doodling extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.DrawingSoftware.Doodling'
    @goal: -> Goal

    @directive: -> "Doodling"

    @instructions: -> """
      Using the software that you chose, try out different drawing (or painting) tools that it offers.
      Try different brush presets if they are available. Use varying pressure with your stylus to get different effects.
    """

    @predecessors: -> [Goal.ChooseSoftware]

    @initialize()

  class @Reference extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.DrawingSoftware.Reference'
    @goal: -> Goal

    @directive: -> "Display a reference"

    @instructions: -> """
      Figure out how you’ll look at a reference image when drawing.
    """

    @predecessors: -> [Goal.Doodling]

    @initialize()

  class @CopyReference extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.DrawingSoftware.CopyReference'
    @goal: -> Goal

    @directive: -> "Copy the reference"

    @instructions: -> """
      Choose one of the objects in the reference and copy it to the best of your ability.
    """

    @interests: -> ['drawing software']

    @predecessors: -> [Goal.Reference]

    @initialize()

  @tasks: -> [
    @ChooseSoftware
    @Doodling
    @Reference
    @CopyReference
  ]

  @finalTasks: -> [
    @CopyReference
  ]

  @initialize()
