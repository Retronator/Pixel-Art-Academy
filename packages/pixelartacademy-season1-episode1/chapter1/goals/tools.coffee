PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.Tools extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Tools'

  @displayName: -> "Learn tools"

  Tools = @

  class @Software extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Tools.Software'
  
    @directive: -> "Choose drawing software"
  
    @instructions: -> """
      Using the Drawing app on PixelBoy, choose which software you want to use to complete drawing assignments.
    """
  
    @initialize()

  # DIY path

  class @Doodling extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Tools.Doodling'

    @directive: -> "Doodling"

    @instructions: -> """
      Doodle on the canvas to see how the basic tools behave. Figure out how to zoom in and out too.
      Upload the image to complete the task.
    """

    @predecessors: -> [Tools.Software]

    @initialize()

  class @AdvancedTools extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Tools.AdvancedTools'

    @directive: -> "Learn advanced tools"

    @instructions: -> """
      Learn how to use the more advanced tools in your software
      (line tool, rectangular selection, lasso selection, move tool, ellipse selection, magic wand).
      They will speed up your process when you work on actual artworks.
    """

    @predecessors: -> [Tools.Doodling]

    @groupNumber: -> -1

    @initialize()

  class @Reference extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Tools.Reference'

    @directive: -> "Display a reference"

    @instructions: -> """
      Figure out how you’ll look at a reference image when drawing in your tool of choice.
    """

    @predecessors: -> [Tools.Doodling]

    @initialize()

  class @Grid extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Tools.Grid'

    @directive: -> "Turn on the grid"

    @instructions: -> """
      Figure out how to show the grid in your software.
      Things to explore: spacing, major vs minor guidelines, grid color and style.
    """

    @predecessors: -> [Tools.Reference]

    @initialize()

  class @CopyReference extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Tools.CopyReference'

    @directive: -> "Copy the reference"

    @instructions: -> """
      Pick one of the sprites from the reference. Black and white is easiest, but if you’ve played with colors already,
      feel free to choose those too. You’ll be counting pixels, which is not at all like drawing something on your own,
      but it's just to practice using the tools to make an actual image.
    """
      
    @interests: -> ['pixel art app', 'drawing tools']

    @predecessors: -> [Tools.Grid]

    @initialize()

  @tasks: -> [
    @Software
    @Doodling
    @AdvancedTools
    @Reference
    @Grid
    @CopyReference
  ]

  @initialize()
