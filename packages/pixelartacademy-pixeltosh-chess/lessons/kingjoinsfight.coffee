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
      The board has emptied out. With few pieces left and the enemy king stranded far away, your king is no longer something to hide. He becomes a fighter.

      March him across the board and capture both of Black's stray pawns.
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

      In the opening you hid your king behind a wall. In the endgame you sent him into battle. The same piece, used in opposite ways.
      
      Knowing when to shelter the king and when to unleash him is one of the deepest skills in all of chess.
    """

    @initialize()
