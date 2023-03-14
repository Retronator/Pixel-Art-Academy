LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Goals.PixelArtSoftware extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware'

  @displayName: -> "Pixel art software"
  
  @chapter: -> LM.Intro.Tutorial

  Goal = @

  # Main path
  class @Editor extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.Editor'
    @goal: -> Goal

    @directive: -> "Select the drawing editor"

    @instructions: -> """
      In the Drawing app, select the Desktop editor on the Settings page.
      More editors will be available in the future.
    """

    @initialize()

    @completedConditions: ->
      PAA.PixelBoy.Apps.Drawing.state('editorId')?

  class @Basics extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.Basics'
    @goal: -> Goal

    @directive: -> "Basics"

    @instructions: -> """
      Learn how to use essential drawing tools (pencil, eraser, color fill)
      by completing the Basics tutorial under Challenges in the Drawing app.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @predecessors: -> [Goal.Editor]

    @initialize()
    
    @completedConditions: ->
      LM.Intro.Tutorial.Challenges.Drawing.Tutorial.Basics.completed()

  class @Helpers extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.Helpers'
    @goal: -> Goal

    @directive: -> "Helpers"

    @instructions: -> """
      Get used to extra tools such as zooming and drawing lines to unlock drawing of big sprites.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @predecessors: -> [Goal.Basics]

    @groupNumber: -> -1

    @initialize()

    @completedConditions: ->
      LM.Intro.Tutorial.Challenges.Drawing.Tutorial.Helpers.completed()

  class @ColorTools extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.ColorTools'
    @goal: -> Goal

    @directive: -> "Colors"

    @instructions: -> """
      Learn how to work with colors to unlock drawing of colored sprites.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @predecessors: -> [Goal.Basics]

    @groupNumber: -> 1

    @initialize()

    @completedConditions: ->
      LM.Intro.Tutorial.Challenges.Drawing.Tutorial.Colors.completed()

  class @CopyReference extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.CopyReference'
    @goal: -> Goal

    @directive: -> "Copy a reference"

    @instructions: -> """
      In the Challenges section of the Drawing app, select a pixel
      art sprite and copy it to show you got the hang of the tools.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @interests: -> ['pixel art software', 'pixel art', 'drawing software']

    @predecessors: -> [Goal.Basics, Goal.Helpers, Goal.ColorTools]
    @predecessorsCompleteType: -> @PredecessorsCompleteType.Any

    @initialize()

    @completedConditions: ->
      assets = LM.Intro.Tutorial.Challenges.Drawing.PixelArtSoftware.state 'assets'
      _.find assets, (asset) => asset.completed

  @tasks: -> [
    @Editor
    @Basics
    @Helpers
    @ColorTools
    @CopyReference
  ]

  @finalTasks: -> [
    @CopyReference
  ]

  @initialize()
