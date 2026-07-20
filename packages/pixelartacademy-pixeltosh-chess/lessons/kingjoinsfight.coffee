PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.KingJoinsFight extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.KingJoinsFight'
  @displayName: -> "The king joins the fight"

  @category: -> Chess.Lessons.Categories.King

  @steps: -> [
    @CapturePawns
    @End
  ]

  @startingPosition: ->
    e1: 'K'
    h8: 'k'
    a5: 'p'
    c3: 'p'

  @initialize()
  
  aiMove: -> @lessonManager.gameState().aiMove 1

  Lesson = @

  class @CapturePawns extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.CapturePawns"

    @message: -> """
      The board has emptied out. With few pieces left to check the king, you can activate him as an attacker.

      March the king across the board and capture both of Black's pawns.
    """

    @retryMessage: -> """
      The pawns got away from your king.

      Try again, and pick a path around the squares they attack.
    """

    @initialize()
    
    retryGameState: -> Chess.GameState.fromPosition @lesson.constructor.startingPosition()
    
    completed: -> @gameState().occupiedSquaresOfColor(Chess.Piece.Colors.Black).length is 1
    
    failed: ->
      return unless gameState = @gameState()
      whiteSquare = gameState.occupiedSquaresOfColor(Chess.Piece.Colors.White)[0]
      blackSquares = gameState.occupiedSquaresOfColor Chess.Piece.Colors.Black
      attackedSquares = gameState.getLegalDestinationsFromSquare whiteSquare
      
      for blackSquare in blackSquares
        blackPiece = gameState.getPieceAtSquare blackSquare
        continue if blackPiece.type is Chess.Piece.Types.Pawn
        continue if blackPiece.type is Chess.Piece.Types.King
        
        # Make sure white can't capture the piece in the next move.
        return true if blackSquare not in attackedSquares
     
      false

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      In the opening you hide your king behind pawns. In the endgame you sent him into battle.
      
      Knowing when to guard the king and when to unleash him is an important piece of chess strategy.
    """

    @initialize()
