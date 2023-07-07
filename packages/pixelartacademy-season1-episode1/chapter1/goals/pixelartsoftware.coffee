PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.PixelArtSoftware extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware'

  @displayName: -> "Pixel art software"
    
  @chapter: -> C1

  Goal = @

  class @DrawingApp extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DrawingApp'
    @goal: -> Goal

    @directive: -> "Get the Drawing app"
  
    @instructions: -> """
      In the Admission Week app, choose to receive the Drawing app for PixelPad.
      Going forward you will decide between using the in-app editor or
      external software to complete drawing assignments.
      Talk to Retro in the store about pixel art software and decide which route to take.
    """

    @initialize()

    completedConditions: ->
      return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      PAA.PixelPad.Apps.Drawing in pixelPad.os.currentAppsSituation().things()

  # Main path
  class @Editor extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Editor'
    @goal: -> Goal

    @directive: -> "Get the drawing editor"

    @instructions: -> """
      Ask Retro for the basic editor for PixelPad and select it on the Settings page in the Drawing app.
      This will give you the ability to edit sprites right in the app.
    """

    @predecessors: -> [Goal.DrawingApp]

    @groupNumber: -> -1

    @initialize()

    @completedConditions: ->
      PAA.PixelPad.Apps.Drawing.state('editorId')?

  class @Basics extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Basics'
    @goal: -> Goal

    @directive: -> "Basics"

    @instructions: -> """
      Learn how to use essential drawing tools (pencil, eraser, color fill)
      by completing the Basics tutorial under Challenges in the Drawing app.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @predecessors: -> [Goal.Editor]

    @groupNumber: -> -1

    @initialize()
    
    @completedConditions: ->
      C1.Challenges.Drawing.Tutorial.Basics.completed()

  class @Helpers extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.Helpers'
    @goal: -> Goal

    @directive: -> "Helpers"

    @instructions: -> """
      Get used to extra tools such as zooming and displaying references in the Helpers tutorial.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @predecessors: -> [Goal.Basics]

    @groupNumber: -> -1

    @initialize()

    @completedConditions: ->
      C1.Challenges.Drawing.Tutorial.Helpers.completed()

  class @ColorTools extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.ColorTools'
    @goal: -> Goal

    @directive: -> "Colors"

    @instructions: -> """
      Learn how to change colors in the Colors tutorial.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @predecessors: -> [Goal.Basics]

    @groupNumber: -> -2

    @initialize()

    @completedConditions: ->
      C1.Challenges.Drawing.Tutorial.Colors.completed()

  # DIY path

  class @DIY
    class @ChooseSoftware extends PAA.Learning.Task.Automatic
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.ChooseSoftware'
      @goal: -> Goal

      @directive: -> "Choose pixel art software"

      @instructions: -> """
        On the Settings page of the Drawing app, choose to use external drawing software for editing pixel art assets.
        This will give you the ability to download and upload sprites once you complete your competency test.
      """

      @predecessors: -> [Goal.DrawingApp]

      @groupNumber: -> 1

      @initialize()

      @completedConditions: ->
        PAA.PixelPad.Apps.Drawing.state('externalSoftware')?

    class @WatchTutorial extends PAA.Learning.Task.Manual
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.WatchTutorial'
      @goal: -> Goal

      @directive: -> "Watch a tutorial"

      @instructions: -> """
        If you want to prepare before we get started, watch a tutorial or two about your software.
        Ask Retro about recommendations.
      """

      @icon: -> PAA.Learning.Task.Icons.Video

      @predecessors: -> [Goal.DIY.ChooseSoftware]

      @groupNumber: -> 2

      @initialize()

    class @Doodling extends PAA.Learning.Task.Upload
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.Doodling'
      @goal: -> Goal

      @directive: -> "Doodling"

      @instructions: -> """
        Using the software of your choice, doodle on the canvas to see how the basic tools behave.
        Figure out how to zoom in and out too. Upload your test drawing to your journal.
      """

      @icon: -> PAA.Learning.Task.Icons.Drawing

      @predecessors: -> [Goal.DIY.ChooseSoftware, Goal.DIY.WatchTutorial]
      @predecessorsCompleteType: -> @PredecessorsCompleteType.Any

      @groupNumber: -> 1

      @initialize()

    class @AdvancedTools extends PAA.Learning.Task.Upload
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.AdvancedTools'
      @goal: -> Goal

      @directive: -> "Learn advanced tools"

      @instructions: -> """
        Learn how to use the more advanced tools in your software
        (line tool, rectangular selection, lasso selection, move tool, ellipse selection, magic wand).
        They will speed up your process when you work on actual artworks.
        Upload a new test image to show things you've tried.
      """

      @icon: -> PAA.Learning.Task.Icons.Drawing

      @predecessors: -> [Goal.DIY.Doodling]

      @groupNumber: -> 2

      @initialize()

    class @Reference extends PAA.Learning.Task.Survey
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.Reference'
      @goal: -> Goal

      @directive: -> "Display the reference"

      @instructions: -> """
        Go to the Pixel Art Software challenge in your Drawing app and download the reference from the assets page.
        Talk to Retro in the Store to learn different ways to set up reference images when drawing.
        Try different approaches and in your journal mark which ways you are going to use.
      """

      @predecessors: -> [Goal.DIY.Doodling, Goal.GetReference]

      @groupNumber: -> 1

      @questions: -> [
        key: 'references'
        type: PAA.Learning.Task.Survey.QuestionType.MultipleChoice
        prompt: "How will you display your references?"
        multipleAnswers: true
        required: true
        choices: [
          key: 'newLayer'
          answer: "New layer in same document"
        ,
          key: 'samePorgram'
          answer: "Opened in same program"
        ,
          key: 'anotherProgram'
          answer: "Opened in another program (image viewer, specialized software)"
        ,
          key: 'secondScreen'
          answer: "On a second screen"
        ,
          key: 'mobileDevice'
          answer: "On a mobile device"
        ,
          key: 'printed'
          answer: "Printed"
        ,
          key: 'other'
          answer: "Other"
          text: true
        ]
      ]

      @initialize()

    class @Grid extends PAA.Learning.Task.Upload
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.DIY.Grid'
      @goal: -> Goal

      @directive: -> "Turn on the grid"

      @instructions: -> """
        Figure out how to show the grid in your software.
        Things to explore: spacing, major vs minor guidelines, grid color and style.
        Take a screenshot of your software with the grid displayed and upload it.
      """

      @predecessors: -> [Goal.DIY.Reference]

      @groupNumber: -> 1

      @initialize()

  class @GetReference extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.GetReference'
    @goal: -> Goal

    @directive: -> "Get a reference"

    @instructions: -> """
      Talk to Corinne in the Gallery and get a reference to copy. It will appear under Challenges in the
      Drawing app.
    """

    @predecessors: -> [Goal.Editor, Goal.DIY.ChooseSoftware]
    @predecessorsCompleteType: -> @PredecessorsCompleteType.Any

    @initialize()

    @completedConditions: ->
      assets = C1.Challenges.Drawing.PixelArtSoftware.state 'assets'
      assets?.length

  class @CopyReference extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PixelArtSoftware.CopyReference'
    @goal: -> Goal

    @directive: -> "Copy the reference"

    @instructions: -> """
      Use the editor or software of your choice to re-create the reference.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @interests: -> ['pixel art software', 'pixel art', 'drawing software']

    @predecessors: -> [Goal.GetReference, Goal.DIY.Grid]
    @predecessorsCompleteType: -> @PredecessorsCompleteType.Any

    @initialize()

    @completedConditions: ->
      assets = C1.Challenges.Drawing.PixelArtSoftware.state 'assets'
      _.find assets, (asset) => asset.completed

  @tasks: -> [
    @DrawingApp

    # Main path
    @Editor
    @Basics
    @Helpers
    @ColorTools

    # DIY
    @DIY.ChooseSoftware
    @DIY.WatchTutorial
    @DIY.Doodling
    @DIY.AdvancedTools
    @DIY.Reference
    @DIY.Grid

    # End
    @GetReference
    @CopyReference
  ]

  @finalTasks: -> [
    @CopyReference
  ]

  @initialize()
