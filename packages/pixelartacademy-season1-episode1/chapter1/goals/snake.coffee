PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.Snake extends C1.Goals.FinalProject
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake'

  @displayName: -> "Snake game"

  @requiredInterests: -> super.concat ['pixel art software']

  class @Play extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Snake.Play'

    @directive: -> "Play the game"

    @instructions: -> """
      Run Pico-8 and try out the game Snake. Notice the art assets included (green snake and brown food).
    """

    @interests: -> ['video game', 'arcade game', 'snake', 'food', 'pico-8']

    @initialize()

  @tasks: -> [
    @Play
  ]

  @initialize()
