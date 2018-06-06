PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.PixelArtSoftware extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware'

  @displayName: -> "Pixel art software"

  Goal = @

  class @ChooseSoftware extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.ChooseSoftware'
  
    @directive: -> "Choose pixel art software"
  
    @instructions: -> """
      Talk to Retro to get the Drawing app for PixelBoy.
      Decide between using the built-in editor or using other software to complete drawing assignments.
    """

    @initialize()

  # Main path

  class @Basics extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Basics'

    @directive: -> "Basics"

    @instructions: -> """
      Learn how to use essential drawing tools (pencil, eraser, color fill)
      by completing the Basics tutorial under Challenges in the Drawing app.
    """

    @predecessors: -> [Goal.ChooseSoftware]

    @initialize()

  class @Helpers extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Helpers'

    @directive: -> "Helpers"

    @instructions: -> """
      Get used to extra tools such as zooming and displaying references in the Helpers tutorial.
    """

    @predecessors: -> [Goal.Basics]


    @initialize()

  class @ColorTools extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.ColorTools'

    @directive: -> "Colors"

    @instructions: -> """
      Learn how to change colors in the Colors tutorial.
    """

    @predecessors: -> [Goal.Basics]

    @groupNumber: -> -1

    @initialize()

  # DIY path

  class @DIY
    class @Doodling extends PAA.Learning.Task
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.Doodling'

      @directive: -> "Doodling (own software)"

      @instructions: -> """
        Using the software of your choice, doodle on the canvas to see how the basic tools behave.
        Figure out how to zoom in and out too. Upload the image to your journal to complete the task.
      """

      @predecessors: -> [Goal.ChooseSoftware]

      @groupNumber: -> 1

      @initialize()

    class @AdvancedTools extends PAA.Learning.Task
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.AdvancedTools'

      @directive: -> "Learn advanced tools"

      @instructions: -> """
        Learn how to use the more advanced tools in your software
        (line tool, rectangular selection, lasso selection, move tool, ellipse selection, magic wand).
        They will speed up your process when you work on actual artworks.
      """

      @predecessors: -> [Goal.DIY.Doodling]

      @groupNumber: -> 2

      @initialize()

    class @Reference extends PAA.Learning.Task
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.Reference'

      @directive: -> "Display a reference"

      @instructions: -> """
        Talk to Alex in the Art Studio to learn different ways to set up reference images when drawing.
      """

      @predecessors: -> [Goal.DIY.Doodling]

      @groupNumber: -> 1

      @initialize()

    class @Grid extends PAA.Learning.Task
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.Grid'

      @directive: -> "Turn on the grid"

      @instructions: -> """
        Figure out how to show the grid in your software.
        Things to explore: spacing, major vs minor guidelines, grid color and style.
      """

      @predecessors: -> [Goal.DIY.Reference]

      @groupNumber: -> 1

      @initialize()

    class @AdvancedSetup extends PAA.Learning.Task
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.AdvancedSetup'

      @directive: -> "Advanced setup"

      @instructions: -> """
        If you're using generic drawing software, there are many things besides the grid that can make working on pixel
        art easier. If there is a tutorial for your software, use it to improve your workspace.
      """

      @predecessors: -> [Goal.DIY.Grid]

      @groupNumber: -> 1

      @initialize()

  class @CopyReference extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.CopyReference'

    @directive: -> "Copy the reference"

    @instructions: -> """
      Talk to Corinne in the Gallery to get some references. Choose one (black and white is easiest,
      but if you’ve played with colors already, go for that too) and re-create it in the Drawing app or
      your software of choice. Upload it to your journal and this goal is complete.
    """

    @interests: -> ['pixel art software', 'pixel art', 'drawing software']

    @predecessors: -> [Goal.Helpers, Goal.DIY.Grid]

    @initialize()

  class @SharingOnline extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.SharingOnline'

    @directive: -> "Sharing online"

    @instructions: -> """
      When you share pixel art online, you have to export it bigger and sometimes with extra space.
      Figure out how to resize the image or apply scale when exporting if your software supports it.
      Talk to Retro to learn about best sizes and tricks for posting to specific social networks.
    """

    @predecessors: -> [Goal.CopyReference]

    @groupNumber: -> 1

    @initialize()

  @tasks: -> [
    @ChooseSoftware

    # Main path
    @Basics
    @Helpers
    @ColorTools

    # DIY
    @DIY.Doodling
    @DIY.AdvancedTools
    @DIY.Reference
    @DIY.Grid
    @DIY.AdvancedSetup

    # End
    @CopyReference
    @SharingOnline
  ]

  @finalTasks: -> [
    @CopyReference
  ]

  @initialize()
