PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.Snake extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake'

  @displayName: -> "Snake game"

  @requiredInterests: -> ['pixel art software']

  Goal = @

  class @Play extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake.Play'

    @directive: -> "Play the game"

    @instructions: -> """
      Run Pico-8 and try out the game Snake. Notice the art assets included (green snake and brown food).
    """

    @interests: -> ['video game', 'arcade game', 'snake', 'food', 'pico-8']

    @initialize()

  class @Draw extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake.Draw'

    @directive: -> "Draw Snake sprites"

    @instructions: -> """
      Go to the Drawing app and draw or upload new sprites for the snake body and food piece.
    """

    @predecessors: -> [Goal.Play]

    @initialize()

  class @PlayAgain extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake.PlayAgain'

    @directive: -> "See sprites in action"

    @instructions: -> """
      Run Pico-8 again and see how your sprites look in the game.
    """

    @interests: -> ['academy of art admission project']

    @predecessors: -> [Goal.Draw]

    @initialize()

  @tasks: -> [
    @Play
    @Draw
    @PlayAgain
  ]

  @finalTasks: -> [
    @PlayAgain
  ]

  @initialize()
