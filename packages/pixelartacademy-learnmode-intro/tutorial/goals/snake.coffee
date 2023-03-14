LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Goals.Snake extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Snake'

  @displayName: -> "Snake game"

  @chapter: -> LM.Intro.Tutorial

  Goal = @
  
  class @Play extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Snake.Play'
    @goal: -> Goal

    @directive: -> "Play the game"

    @instructions: -> """
      In the PICO-8 app, try out the game Snake. Notice the art assets included (green snake and brown food).
      Score at least 5 points to continue.
    """

    @interests: -> ['pico-8', 'gaming']

    @initialize()

    @completedConditions: ->
      return false
      
      # TODO: Add Snake project.
      # Make sure the player has the Snake cartridge.
      return unless LM.Intro.Tutorial.AdmissionProjects.Snake.Intro.Coworking.Listener.Script.state 'ReceiveCartridge'

      # Require score of 5 or higher. Since we reset the high score when the
      # intro section is finished, we also keep this task completed based on that.
      PAA.Pico8.Cartridges.Snake.state('highScore') >= 5 or LM.Intro.Tutorial.AdmissionProjects.Snake.Intro.finished()

  class @Draw extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Snake.Draw'
    @goal: -> Goal

    @directive: -> "Draw Snake sprites"

    @instructions: -> """
      After you get familiar with pixel art software, draw new sprites
      for the snake body and food piece in the Projects section of the Drawing app.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @interests: -> ['snake', 'food']

    @predecessors: -> [Goal.Play]

    @requiredInterests: -> ['pixel art software']

    @initialize()
    
    @completedConditions: ->
      return unless projectId = PAA.Pico8.Cartridges.Snake.Project.readOnlyState 'activeProjectId'

      PAA.Practice.Project.forId.subscribe projectId
      return unless project = PAA.Practice.Project.documents.findOne projectId

      for asset in project.assets
        LOI.Assets.Asset.forId.subscribe LOI.Assets.Sprite.className, asset.sprite._id
        return unless sprite = LOI.Assets.Sprite.documents.findOne asset.sprite._id

        # We know the player has changed the sprite if the history position is not zero.
        return unless sprite.historyPosition

      true

  class @PlayAgain extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Snake.PlayAgain'
    @goal: -> Goal

    @directive: -> "See sprites in action"

    @instructions: -> """
      With the game sprites replaced, run PICO-8 again and see how your art looks in the game. Do any updates until
      you're happy. Score at least 10 points to complete the project.
    """

    @interests: -> ['learn mode tutorial project']

    @predecessors: -> [Goal.Draw]

    @initialize()

    @completedConditions: ->
      LM.Intro.Tutorial.AdmissionProjects.Snake.Drawing.Coworking.Listener.Script.state 'AdmissionProjectCompleted'

  @tasks: -> [
    @Play
    @Draw
    @PlayAgain
  ]

  @finalTasks: -> [
    @PlayAgain
  ]

  @initialize()
