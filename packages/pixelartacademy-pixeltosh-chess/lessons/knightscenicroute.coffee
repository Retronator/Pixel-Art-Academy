PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.KnightScenicRoute extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.KnightScenicRoute'
  @displayName: -> "The knight's scenic route"

  @category: -> Chess.Lessons.Categories.Knight

  @steps: -> [
    @ReachNeighborSquare
    @End
  ]

  @startingPosition: ->
    d4: 'N'

  @initialize()

  Lesson = @

  class @ReachNeighborSquare extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.ReachNeighborSquare"

    @message: -> """
      The square ahead looks close, yet it's out of reach. A knight can never land on a neighbor square in a single move.

      Take the long way around. Reach d5.
    """

    @requiredPosition: ->
      d5: 'N'

    @initialize()

    markup: -> [
      target:
        position: Chess.Square.d5
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      Getting next door costs a knight three moves. Spend them well: a knight rerouted to the right square repays every step.
    """

    @initialize()
