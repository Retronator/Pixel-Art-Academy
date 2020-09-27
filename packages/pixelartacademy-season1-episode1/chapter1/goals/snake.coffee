PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.Snake extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake'

  @displayName: -> "Snake game"

  @chapter: -> C1

  Goal = @

  class @Talk extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake.Talk'
    @goal: -> Goal

    @directive: -> "Talk to Reuben"

    @instructions: -> """
      Go to Retronator HQ coworking space and talk to Reuben about working on the Snake game.
    """

    @interests: -> ['video game', 'arcade game']

    @initialize()

    @completedConditions: ->
      C1.AdmissionProjects.Snake.Intro.Coworking.Listener.Script.state 'OfferedHelp'

  class @Play extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake.Play'
    @goal: -> Goal

    @directive: -> "Play the game"

    @instructions: -> """
      Get PICO-8 and try out the game Snake. Notice the art assets included (green snake and brown food).
      Score at least 5 points to continue.
    """

    @interests: -> ['pico-8', 'gaming']

    @predecessors: -> [Goal.Talk]

    @initialize()

    @completedConditions: ->
      # Make sure the player has the Snake cartridge.
      return unless C1.AdmissionProjects.Snake.Intro.Coworking.Listener.Script.state 'ReceiveCartridge'

      # Require score of 5 or higher. Since we reset the high score when the
      # intro section is finished, we also keep this task completed based on that.
      PAA.Pico8.Cartridges.Snake.state('highScore') >= 5 or C1.AdmissionProjects.Snake.Intro.finished()

  class @Draw extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake.Draw'
    @goal: -> Goal

    @directive: -> "Draw Snake sprites"

    @instructions: -> """
      Talk to Reuben about drawing the game sprites. After you get familiar with pixel art software, draw new sprites
      for the snake body and food piece in the Projects section of the Drawing app.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @interests: -> ['snake', 'food']

    @predecessors: -> [Goal.Play]

    @requiredInterests: -> ['pixel art software']

    @initialize()
    
    @completedConditions: ->
      return unless projectId = C1.Projects.Snake.readOnlyState 'activeProjectId'

      PAA.Practice.Project.forId.subscribe projectId
      return unless project = PAA.Practice.Project.documents.findOne projectId

      for asset in project.assets
        LOI.Assets.Asset.forId.subscribe LOI.Assets.Sprite.className, asset.sprite._id
        return unless sprite = LOI.Assets.Sprite.documents.findOne asset.sprite._id

        # We know the player has changed the sprite if the history position is not zero.
        return unless sprite.historyPosition

      true

  class @PlayAgain extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake.PlayAgain'
    @goal: -> Goal

    @directive: -> "See sprites in action"

    @instructions: -> """
      With the game sprites replaced, run Pico-8 again and see how your art looks in the game. Do any updates until
      you're happy. Score at least 10 points and talk to Reuben to complete the project.
    """

    @interests: -> ['academy of art admission project']

    @predecessors: -> [Goal.Draw]

    @initialize()

    @completedConditions: ->
      C1.AdmissionProjects.Snake.Drawing.Coworking.Listener.Script.state 'AdmissionProjectCompleted'

  @tasks: -> [
    @Talk
    @Play
    @Draw
    @PlayAgain
  ]

  @finalTasks: -> [
    @PlayAgain
  ]

  @initialize()
