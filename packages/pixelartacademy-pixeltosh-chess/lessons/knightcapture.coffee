PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.KnightCapture extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.KnightCapture'
  @displayName: -> "Knight capture"

  @category: -> Chess.Lessons.Categories.Knight

  @steps: -> [
    @CapturePawn
    @End
  ]

  @startingPosition: ->
    d4: 'N'
    e6: 'p'

  @initialize()
  
  aiMove: -> @randomAICapture() or @randomAIMove()

  Lesson = @

  class @CapturePawn extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.CapturePawn"

    @message: -> """
      A knight captures just as it moves—by landing on the enemy.

      Capture the pawn.
    """

    @retryPosition: -> Lesson.startingPosition()

    completed: ->
      not @gameState().occupiedSquaresOfColor(Chess.Piece.Colors.Black).length

    failed: ->
      gameState = @gameState()
      return true unless gameState.getPiecesOfColor(Chess.Piece.Colors.White).length
      
      return unless blackPiece = gameState.getPiecesOfColor(Chess.Piece.Colors.Black)[0]
      return unless blackPiece.type is Chess.Piece.Types.Queen
      
      # Make sure the knight can't capture the queen in the next move.
      queenSquare = gameState.occupiedSquaresOfColor(Chess.Piece.Colors.Black)[0]
      knightSquare = gameState.occupiedSquaresOfColor(Chess.Piece.Colors.White)[0]
      
      fileDistance = Math.abs queenSquare.fileIndex - knightSquare.fileIndex
      rankDistance = Math.abs queenSquare.rankIndex - knightSquare.rankIndex

      not ((fileDistance is 2 and rankDistance is 1) or (fileDistance is 1 and rankDistance is 2))
    
    @retryMessage: -> """
      You missed your moment, the pawn was able to get the best of you.

      Try again by capturing the pawn while you have the chance.
    """

    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      Because the knight jumps, nothing can block its attack. The only defense is to move the target or guard it.
    """

    @initialize()
