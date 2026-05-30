PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.TwoBishopsTwoColours extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.TwoBishopsTwoColours'
  @displayName: -> "Two bishops, two colours"

  @category: -> Chess.Lessons.Categories.Bishop

  @steps: -> [
    @ReachLightSquare
    @ReachDarkSquare
    @ReachLightSquareAgain
    @End
  ]

  @startingPosition: ->
    c1: 'B'
    f1: 'B'

  @initialize()

  Lesson = @

  class @ReachLightSquare extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.ReachLightSquare"

    @message: -> """
      Your two bishops split the board between them. One rules the light squares, the other the dark.

      A target on a light square: send the bishop that can reach it.
    """

    @requiredPosition: ->
      c6: 'B'

    @initialize()

    markup: -> [
      target:
        position: Chess.Square.c6
    ]

  class @ReachDarkSquare extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.ReachDarkSquare"

    @message: -> """
      A new target on e5.

      Reach it!
    """

    @requiredPosition: ->
      e5: 'B'

    @initialize()

    markup: -> [
      target:
        position: Chess.Square.e5
    ]

  class @ReachLightSquareAgain extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.ReachLightSquareAgain"

    @message: -> """
      Final one!

      Reach the target on d3.
    """

    @requiredPosition: ->
      d3: 'B'

    @initialize()

    markup: -> [
      target:
        position: Chess.Square.d3
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      Each bishop covers only half the squares on the board. Together they miss nothing, which is why the two of them—the bishop pair—are such a prize.
    """

    @initialize()
