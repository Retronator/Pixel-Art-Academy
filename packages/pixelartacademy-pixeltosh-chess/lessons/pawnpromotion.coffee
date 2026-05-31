PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.PawnPromotion extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.PawnPromotion'
  @displayName: -> "Pawn promotion"

  @category: -> Chess.Lessons.Categories.Pawn

  @steps: -> [
    @AdvanceToLastRank
    @ChoosePromotion
    @End
  ]

  @startingPosition: ->
    d7: 'P'
    
  @additionalRequiredPieces: -> Chess.Piece.PromotionTypes

  @initialize()

  Lesson = @

  class @AdvanceToLastRank extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.AdvanceToLastRank"

    @message: -> """
      Your pawn stands one step from the far edge. See what happens when you reach it.

      Advance to d8.
    """

    @requiredPosition: ->
      d7: null

    @initialize()

  class @ChoosePromotion extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.ChoosePromotion"

    @message: -> """
      A pawn that reaches the last rank doesn't stop—it promotes into a stronger piece.

      Choose what your pawn becomes.
    """

    @initialize()

    completed: ->
      return unless piece = @gameState().getPieceAtSquare Chess.Square.d8
      piece.type isnt Chess.Piece.Types.Pawn
      
    failed: ->
      return true if @lesson.lessonManager.rewinding()
      
      return if @_failed
      return unless @positionAchieved d7: 'P'
      
      @_failed = true
    
    @retryMessage: -> """
      You closed the menu without choosing.
      
      Advance to d8 again, then pick the piece your pawn becomes.
    """
    
  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      The far rank turns your humblest soldier into a mighty one—almost always a queen. Every pawn carries a crown in its knapsack.
    """

    @initialize()
