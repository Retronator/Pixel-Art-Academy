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
      With the Drawing app on PixelBoy, choose which pixel art software you want to use to complete drawing assignments.
    """

    @initialize()

  # Main path

  class @Pencil extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Pencil'

    @directive: -> "Pencil"

    @instructions: -> """
      Try your first tool in the Drawing app: the pencil!
    """

    @predecessors: -> [Goal.ChooseSoftware]

    @initialize()

  class @Eraser extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Eraser'

    @directive: -> "Eraser"

    @instructions: -> """
      Delete pixels with the eraser.
    """

    @predecessors: -> [Goal.Pencil]

    @initialize()

  class @BucketFill extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.BucketFill'

    @directive: -> "Bucket fill"

    @instructions: -> """
      Speed up coloring by using the bucket tool. Now you have the essential tools to do black and white pixel art.
    """

    @predecessors: -> [Goal.Pencil]

    @groupNumber: -> -1

    @initialize()

  class @Colors extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Colors'

    @directive: -> "Colors"

    @instructions: -> """
      Learn how to use the color palette.
    """

    @predecessors: -> [Goal.Pencil]

    @groupNumber: -> -2

    @initialize()

  class @ColorPicking extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.ColorPicking'

    @directive: -> "Color picking"

    @instructions: -> """
      Use color picking to speed up changing colors.
    """

    @predecessors: -> [Goal.Colors, Goal.Shortcuts]

    @groupNumber: -> -2

    @initialize()

  class @Shortcuts extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Shortcuts'

    @directive: -> "Learn shortcuts"

    @instructions: -> """
      Use the shortcuts menu to see or reassign keyboard shortcuts and increase your drawing efficiency.
    """

    @predecessors: -> [Goal.Eraser, Goal.BucketFill]

    @groupNumber: -> -1

    @initialize()

  class @Lines extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Lines'

    @directive: -> "Lines"

    @instructions: -> """
      Quickly draw lines with the pencil by shift-clicking.
    """

    @predecessors: -> [Goal.Shortcuts]

    @groupNumber: -> -1

    @initialize()

  class @Reference extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Reference'

    @directive: -> "Display a reference"

    @instructions: -> """
      Learn how to display your own references.
    """

    @predecessors: -> [Goal.Eraser]

    @initialize()

  # DIY path

  class @DIY
    class @Doodling extends PAA.Learning.Task
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.Doodling'

      @directive: -> "Doodling (own software)"

      @instructions: -> """
        Using the software that you chose, doodle on the canvas to see how the basic tools behave.
        Figure out how to zoom in and out too. Upload the image to complete the task.
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
        Figure out how you’ll look at a reference image when drawing in your tool of choice.
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

  class @CopyReference extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.CopyReference'

    @directive: -> "Copy the reference"

    @instructions: -> """
      Pick one of the sprites from the reference. Black and white is easiest, but if you’ve played with colors already,
      feel free to choose those too.
    """

    @interests: -> ['pixel art software', 'pixel art', 'drawing software']

    @predecessors: -> [Goal.Reference, Goal.DIY.Grid]

    @initialize()

  @tasks: -> [
    @ChooseSoftware

    # Main path
    @Pencil
    @Eraser
    @BucketFill
    @Colors
    @ColorPicking
    @Shortcuts
    @Lines
    @Reference

    # DIY
    @DIY.Doodling
    @DIY.AdvancedTools
    @DIY.Reference
    @DIY.Grid

    # End
    @CopyReference
  ]

  @finalTasks: -> [
    @CopyReference
  ]

  @initialize()
