PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.RespectTheQueen extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.RespectTheQueen'
  @displayName: -> "Respect the queen"

  @category: -> Chess.Lessons.Categories.Queen

  @steps: -> [
    @MoveToSafety
    @WinThePawns
    @End
  ]

  @startingPosition: ->
    d5: 'Q'
    c6: 'p'
    b7: 'p'

  @initialize()

  aiMove: -> @randomAICapture() or @randomAIMove()

  Lesson = @

  class @MoveToSafety extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.MoveToSafety"

    @message: -> """
      Your queen is under attack from the c6 pawn, and she could snatch it up at once. But look before you leap. Is that pawn defended?

      What should you do?
    """

    @retryMessage: -> """
      And there goes your queen, traded for a single pawn. The pawn on c6 was guarded by the one on b7.

      Before you grab material, always check what defends it. Let's rewind, and this time lead your queen quietly out of danger.
    """

    @initialize()

    completed: ->
      gameState = @gameState()

      queenSaved = gameState.getPiecesOfColor(Chess.Piece.Colors.White).length and gameState.turn() is Chess.Piece.Colors.White and @positionAchieved d5: null
      queenLostWithoutTrade = not gameState.getPiecesOfColor(Chess.Piece.Colors.White).length and gameState.getPiecesOfColor(Chess.Piece.Colors.Black).length is 2

      queenSaved or queenLostWithoutTrade
    
    failed: ->
      return unless gameState = @gameState()
      not gameState.getPiecesOfColor(Chess.Piece.Colors.White).length and gameState.getPiecesOfColor(Chess.Piece.Colors.Black).length is 1
  
  class @WinThePawns extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.WinThePawns"
    
    @message: -> """
      Well done. She lives to fight another day.

      How can you win the pawns without getting your queen in trouble?
    """
    
    @retryMessage: -> """
      And there goes your queen, outmaneuvered by a simple pawn.

      Before you grab material or move to a square, always check what defends it.
      
      Let's rewind, and choose a different path to win the pawns.
    """
    
    @initialize()
    
    retryGameState: -> Chess.GameState.fromPosition @lesson.constructor.startingPosition()
    
    completed: -> not @gameState().occupiedSquaresOfColor(Chess.Piece.Colors.Black).length
    
    failed: ->
      return unless gameState = @gameState()
      return true unless whiteSquare = gameState.occupiedSquaresOfColor(Chess.Piece.Colors.White)[0]
      
      blackSquares = gameState.occupiedSquaresOfColor Chess.Piece.Colors.Black
      return unless blackSquares.length
      
      attackedSquares = gameState.getLegalDestinationsFromSquare whiteSquare
      
      for blackSquare in blackSquares
        blackPiece = gameState.getPieceAtSquare blackSquare
        continue if blackPiece.type is Chess.Piece.Types.Pawn
        
        # Make sure white can't capture the piece in the next move.
        return true if blackSquare not in attackedSquares
     
      false
      
  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      The queen's power is exactly what makes her precious. Never trade her for less without good reason, and never leave her on a square where a humbler piece can win her.
    """

    @initialize()
