PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.BlockedRook extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.BlockedRook'
  @displayName: -> "The blocked rook"

  @category: -> Chess.Lessons.Categories.Rook

  @steps: -> [
    @SlideToBlocker
    @ReachTarget
    @End
  ]

  @startingPosition: ->
    d2: 'R'
    d3: 'P'

  @initialize()

  Lesson = @

  class @SlideToBlocker extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.SlideToBlocker"

    @message: -> """
      Your pawn is in the way and the rook can't jump over it.

      You'll have to go around.
    """

    @initialize()
    
    completed: ->
      gameState = @gameState()
      not gameState.isSquareOccupied(Chess.Square.d2) or not gameState.isSquareOccupied(Chess.Square.d3)

    markup: -> [
      arrows: [
        from: Chess.Square.d2
        to: Chess.Square.h2
      ,
        from: Chess.Square.d2
        to: Chess.Square.a2
      ,
        from: Chess.Square.d2
        to: Chess.Square.d1
      ]
      target:
        position: Chess.Square.d8
    ]

  class @ReachTarget extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.ReachTarget"

    @message: -> """
      Reach the target on d8.
    """

    @initialize()
    
    @requiredPosition: ->
      d8: 'R'

    markup: -> [
      target:
        position: Chess.Square.d8
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      Rooks are well positioned on files (columns), where one or both pawns are already missing.
    """

    @initialize()
