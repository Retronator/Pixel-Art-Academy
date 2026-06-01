PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.KingDanger extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.KingDanger'
  @displayName: -> "The king can't walk into danger"

  @category: -> Chess.Lessons.Categories.King

  @steps: -> [
    @ReachNearTarget
    @End
  ]

  @startingPosition: ->
    h1: 'K'
    a4: 'r'
    a5: 'k'

  @initialize()
  
  aiMove: ->
    gameState = @lessonManager.gameState()
    kingSquare = gameState.occupiedSquaresByPiecesOfColor(Chess.Piece.Types.King, Chess.Piece.Colors.Black)[0]
    new Chess.Move kingSquare, Chess.Square[(kingSquare.fileIndex + 1) % 2][kingSquare.rankIndex]

  Lesson = @

  class @ReachNearTarget extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.ReachNearTarget"

    @message: -> """
      A target waits on d4. Bring your king to it.
    """

    @requiredPosition: -> d3: 'K'

    @initialize()

    markup: -> [
      target:
        position: Chess.Square.d4
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      So close, yet you cannot take the final step.

      The rook guards the entire fourth rank, d4 along with it. A king may never move onto a square the enemy attacks, because that would walk him straight into check, and that is forbidden. Of every piece, the king alone must always stay out of danger.
    """

    @initialize()

    markup: -> [
      target:
        position: Chess.Square.d4
      arrow:
        from: Chess.Square.a4
        to: Chess.Square.h4
    ]
