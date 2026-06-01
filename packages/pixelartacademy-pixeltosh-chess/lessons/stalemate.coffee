PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.Stalemate extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.Stalemate'
  @displayName: -> "Stalemate"

  @category: -> Chess.Lessons.Categories.King

  @steps: -> [
    @WalkIntoStalemate
    @End
  ]

  @startingPosition: ->
    f7: 'K'
    h8: 'k'
    g5: 'P'

  @initialize()
  
  aiMove: -> @lessonManager.gameState().aiMove()

  Lesson = @

  class @WalkIntoStalemate extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.WalkIntoStalemate"

    @message: -> """
      A lone king can't deliver checkmate, so let's promote our pawn to a queen.

      Push the pawn forward.
    """
    
    @requiredPosition: -> g6: 'P'
    
    @failedPosition: -> g5: 'P', f7: null

    @retryMessage: -> """
      This is useful, but Let's push the pawn anyway, to see what happens.

      Move the pawn to g6.
    """

    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      It was a trap!

      Your king and pawn cover every square around the black king, yet he is not in check himself. Black has no move, but isn't beaten either.

      This is stalemate. The game is a draw.
    """

    @initialize()
    
    markup: -> [
      arrows: [
        from: Chess.Square.g6
        to: Chess.Square.h7
      ,
        from: Chess.Square.g6
        to: Chess.Square.f7
      ,
        from: Chess.Square.f7
        to: Chess.Square.g8
      ,
        from: Chess.Square.f7
        to: Chess.Square.g7
      ,
        from: Chess.Square.f7
        to: Chess.Square.g6
      ,
        from: Chess.Square.f7
        to: Chess.Square.f6
      ,
        from: Chess.Square.f7
        to: Chess.Square.e6
      ,
        from: Chess.Square.f7
        to: Chess.Square.e7
      ,
        from: Chess.Square.f7
        to: Chess.Square.e8
      ,
        from: Chess.Square.f7
        to: Chess.Square.f8
      ]
    ]
