PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.Checkmate extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.Checkmate'
  @displayName: -> "Checkmate"

  @category: -> Chess.Lessons.Categories.King

  @steps: -> [
    @DeliverCheckmate
    @End
  ]

  @startingPosition: ->
    e1: 'K'
    a1: 'R'
    g8: 'k'
    f7: 'p'
    g7: 'p'
    h7: 'p'

  @initialize()
  
  aiMove: -> @randomAIMoveByPiece Chess.Piece.Types.Pawn

  Lesson = @

  class @DeliverCheckmate extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.DeliverCheckmate"

    @message: -> """
      The black king is boxed in by his own pawns, with no way out of a potential check. Your rook can end the game in a single move.

      Deliver checkmate: a check the king cannot escape.
    """
    
    @retryMessage: -> """
      Black was able to give the king some breathing room, so the chance for checkmate in one move is gone.

      Rewind and force checkmate from a8.
    """

    @initialize()

    completed: -> @gameState().checkMate()
    
    failed: -> @positionAchieved(f7: null) or @positionAchieved(g7: null) or @positionAchieved(h7: null)

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done! That is checkmate.

      Black has nowhere to move, nothing to block with, and no way to capture the attacker. The game is over. This is the goal of every game of chess.
    """

    @initialize()
