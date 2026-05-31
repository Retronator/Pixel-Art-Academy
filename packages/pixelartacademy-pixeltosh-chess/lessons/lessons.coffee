PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons
  class @DefaultEndStep extends Chess.Lesson.EndStep
    @id: -> "PAA.Pixeltosh.Programs.Chess.Lessons.DefaultEndStep"
    
    @message: -> """
      Well done!
    """
    
    @initialize()

  class @CapturePawn extends Chess.Lesson.Step
    @retryMessage: -> """
      You missed your moment, the pawn was able to get the best of you.

      Try again by capturing the pawn while you have the chance.
    """
    
    retryGameState: -> Chess.GameState.fromPosition @lesson.constructor.startingPosition()

    completed: -> not @gameState().occupiedSquaresOfColor(Chess.Piece.Colors.Black).length

    failed: ->
      gameState = @gameState()
      return true unless gameState.getPiecesOfColor(Chess.Piece.Colors.White).length
      
      return unless blackPiece = gameState.getPiecesOfColor(Chess.Piece.Colors.Black)[0]
      return if blackPiece.type is Chess.Piece.Types.Pawn
      
      # Make sure white can't capture the piece in the next move.
      blackSquare = gameState.occupiedSquaresOfColor(Chess.Piece.Colors.Black)[0]
      whiteSquare = gameState.occupiedSquaresOfColor(Chess.Piece.Colors.White)[0]
      blackSquare not in gameState.getLegalDestinationsFromSquare whiteSquare
