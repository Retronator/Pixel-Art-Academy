PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.PixelArtSoftware extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware'

  @displayName: -> "Pixel art software"

  Goal = @

  class @DrawingApp extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DrawingApp'
  
    @directive: -> "Get the Drawing app"
  
    @instructions: -> """
      In the Admission Week app, choose to receive the Drawing app for PixelBoy.
      Going forward you will decide between using the in-app editor or
      external software to complete drawing assignments.
      Talk to Alexandra in the art studio if you need help deciding which route to take.
    """

    @initialize()

    completed: ->
      return unless pixelBoy = LOI.adventure.getCurrentThing PAA.PixelBoy
      PAA.PixelBoy.Apps.Drawing in pixelBoy.os.currentAppsSituation().things()

  # Main path
  class @Editor extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Editor'

    @directive: -> "Get the drawing editor"

    @instructions: -> """
      Ask Alexandra for the basic editor for PixelBoy and select it on the Settings page in the Drawing app.
      This will give you the ability to edit sprites right in the app.
    """

    @predecessors: -> [Goal.DrawingApp]

    @groupNumber: -> -1

    @initialize()

    @completed: ->
      PAA.PixelBoy.Apps.Drawing.state('editorId')?

  class @Basics extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Basics'

    @directive: -> "Basics"

    @instructions: -> """
      Learn how to use essential drawing tools (pencil, eraser, color fill)
      by completing the Basics tutorial under Challenges in the Drawing app.
    """

    @predecessors: -> [Goal.Editor]

    @groupNumber: -> -1

    @initialize()
    
    @completed: ->
      C1.Challenges.Drawing.Tutorial.Basics.completed()

  class @Helpers extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Helpers'

    @directive: -> "Helpers"

    @instructions: -> """
      Get used to extra tools such as zooming and displaying references in the Helpers tutorial.
    """

    @predecessors: -> [Goal.Basics]

    @groupNumber: -> -1

    @initialize()

    @completed: ->
      C1.Challenges.Drawing.Tutorial.Helpers.completed()

  class @ColorTools extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.ColorTools'

    @directive: -> "Color tools"

    @instructions: -> """
      Learn how to change colors in the Color tools tutorial.
    """

    @predecessors: -> [Goal.Basics]

    @groupNumber: -> -2

    @initialize()

    @completed: ->
      C1.Challenges.Drawing.Tutorial.Colors.completed()

  # DIY path

  class @DIY
    class @ChooseSoftware extends PAA.Learning.Task
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.ChooseSoftware'

      @directive: -> "Choose pixel art software"

      @instructions: -> """
        On the Settings page of the Drawing app, choose to use external drawing software for editing pixel art assets.
        This will give you the ability to download and upload sprites once you complete your competency test.
      """

      @predecessors: -> [Goal.DrawingApp]

      @groupNumber: -> 1

      @initialize()

      @completed: ->
        PAA.PixelBoy.Apps.Drawing.state('externalSoftware')?

    class @Doodling extends PAA.Learning.Task
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.Doodling'

      @directive: -> "Doodling"

      @instructions: -> """
        Using the software of your choice, doodle on the canvas to see how the basic tools behave.
        Figure out how to zoom in and out too. Upload the image to your journal to complete the task.
      """

      @predecessors: -> [Goal.DIY.ChooseSoftware]

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
        Talk to Alexandra in the Art Studio to learn different ways to set up reference images when drawing.
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
      Talk to Corinne in the Gallery and get a reference to copy. It will appear under Challenges in the
      Drawing app. Use the editor or software of your choice to re-create the reference.
    """

    @interests: -> ['pixel art software', 'pixel art', 'drawing software']

    @predecessors: -> [Goal.Editor, Goal.DIY.ChooseSoftware]
    @predecessorsCompleteType: -> @PredecessorsCompleteType.Any

    @initialize()

  @tasks: -> [
    @DrawingApp

    # Main path
    @Editor
    @Basics
    @Helpers
    @ColorTools

    # DIY
    @DIY.ChooseSoftware
    @DIY.Doodling
    @DIY.AdvancedTools
    @DIY.Reference
    @DIY.Grid
    @DIY.AdvancedSetup

    # End
    @CopyReference
  ]

  @finalTasks: -> [
    @CopyReference
  ]

  @initialize()
