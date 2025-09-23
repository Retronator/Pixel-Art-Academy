LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Goals.Snake extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Snake'

  @displayName: -> "Snake game"

  @chapter: -> LM.Intro.Tutorial
  
  reset: ->
    PAA.Pico8.Cartridges.state 'Snake', null
    super arguments...

  Goal = @
  
  class @Play extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Snake.Play'
    @goal: -> Goal

    @directive: -> "Play the game"

    @instructions: -> """
      In the PICO-8 app, try out the game Snake. Notice the art assets included (green snake and brown food).
      Score some points to continue.
    """

    @interests: -> ['pico-8', 'gaming']

    @requiredInterests: -> ['pixel art software']

    @initialize()

    @completedConditions: ->
      # Require score of 1 or higher. Since we reset the high score when the
      # snake project is created, we also keep this task completed based on that.
      PAA.Pico8.Cartridges.Snake.state('highScore') >= 1 or PAA.Pico8.Cartridges.Snake.Project.state 'activeProjectId'

  class @Draw extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Snake.Draw'
    @goal: -> Goal

    @directive: -> "Draw Snake sprites"

    @instructions: -> """
      In the Drawing app, find the Snake art assets in the Projects section.
      Redraw the sprites for the snake body and the food piece.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @interests: -> ['snake', 'food']

    @predecessors: -> [Goal.Play]

    @initialize()
    
    @completedConditions: ->
      return unless projectId = PAA.Pico8.Cartridges.Snake.Project.state 'activeProjectId'
      return unless project = PAA.Practice.Project.documents.findOne projectId

      for asset in project.assets
        return unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId

        # We know the player has changed the bitmap if the history position is not zero.
        return unless bitmap.historyPosition

      true
      
    onActiveDisplayed: ->
      # Reset high score again to force replay, in case the player continued to play the game after the first time.
      PAA.Pico8.Cartridges.Snake.state 'highScore', 0

  class @PlayAgain extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Snake.PlayAgain'
    @goal: -> Goal

    @directive: -> "See sprites in action"

    @instructions: -> """
      With the game sprites replaced, run PICO-8 again and see how your art looks in the game. Do any updates until
      you're happy. Score some more points to complete the project.
    """

    @interests: -> ['learn mode tutorial project']

    @predecessors: -> [Goal.Draw]

    @initialize()

    @completedConditions: ->
      PAA.Pico8.Cartridges.Snake.state('highScore') >= 1
      
  @tasks: -> [
    @Play
    @Draw
    @PlayAgain
  ]

  @finalTasks: -> [
    @PlayAgain
  ]

  @initialize()
