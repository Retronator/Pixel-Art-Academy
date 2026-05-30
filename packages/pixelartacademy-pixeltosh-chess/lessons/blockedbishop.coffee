PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.BlockedBishop extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.BlockedBishop'
  @displayName: -> "The blocked bishop"

  @category: -> Chess.Lessons.Categories.Bishop

  @steps: -> [
    @UnderstandBlock
    @ReachTarget
    @End
  ]

  @startingPosition: ->
    d4: 'B'
    f6: 'P'

  @initialize()

  Lesson = @

  class @UnderstandBlock extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.UnderstandBlock"

    @message: -> """
      The bishop glides along a diagonal, but it can't jump over a single thing.

      To reach the target, you will have to go around, or push the pawn.
    """

    @initialize()

    completed: ->
      gameState = @gameState()
      not gameState.isSquareOccupied(Chess.Square.d4) or not gameState.isSquareOccupied(Chess.Square.f6)

    markup: -> [
      arrows: [
        from: Chess.Square.d4
        to: Chess.Square.e5
      ,
        from: Chess.Square.d4
        to: Chess.Square.a7
      ,
        from: Chess.Square.d4
        to: Chess.Square.a1
      ,
        from: Chess.Square.d4
        to: Chess.Square.g1
      ]
      target:
        position: Chess.Square.h8
    ]

  class @ReachTarget extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.ReachTarget"

    @message: -> """
      Reach the target on h8.
    """

    @requiredPosition: ->
      h8: 'B'

    @initialize()

    markup: -> [
      target:
        position: Chess.Square.h8
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      A single piece on a diagonal cuts a bishop's reach down. Bishops are long-range snipers, but only down open lines.
    """

    @initialize()
