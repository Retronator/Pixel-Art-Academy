PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.Snake extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake'

  @displayName: -> "Snake game"

  Goal = @

  class @Talk extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake.Talk'

    @directive: -> "Talk to Reuben"

    @instructions: -> """
      Go to Retronator HQ coworking space and talk to Reuben about working on the Snake game.
    """

    @interests: -> ['video game', 'arcade game']

    @initialize()
    
    @completed: ->
      C1.AdmissionProjects.Snake.Intro.Coworking.Listener.Script.state 'OfferedHelp'

  class @Play extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake.Play'

    @directive: -> "Play the game"

    @instructions: -> """
      Get PICO-8 and try out the game Snake. Notice the art assets included (green snake and brown food).
      Score at least 5 points to continue.
    """

    @interests: -> ['pico-8', 'gaming']

    @predecessors: -> [Goal.Talk]

    @initialize()

    @completed: ->
      # Make sure the player has the Snake cartridge.
      return unless C1.AdmissionProjects.Snake.Intro.Coworking.Listener.Script.state 'ReceiveCartridge'

      # Require score of 5 or higher.
      PAA.Pico8.Cartridges.Snake.state('highScore') >= 5

  class @Draw extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake.Draw'

    @directive: -> "Draw Snake sprites"

    @instructions: -> """
      Talk to Reuben about drawing the game sprites. After you get familiar with pixel art software, draw new sprites
      for the snake body and food piece in the Projects section of the Drawing app.
    """

    @interests: -> ['snake', 'food']

    @predecessors: -> [Goal.Play]

    # TODO: @requiredInterests: -> ['pixel art software']

    @initialize()
    
    @completed: ->

  class @PlayAgain extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake.PlayAgain'

    @directive: -> "See sprites in action"

    @instructions: -> """
      With the game sprites replaced, run Pico-8 again and see how your art looks in the game. Do any updates until
      you're happy. Score at least 10 points and talk to Reuben to complete the project.
    """

    @interests: -> ['academy of art admission project']

    @predecessors: -> [Goal.Draw]

    @initialize()

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
