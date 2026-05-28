PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.EnPassant extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.EnPassant'
  @displayName: -> "En passant"

  @category: -> Chess.Lessons.Categories.Pawn

  @steps: -> [
    @AdvanceToFifthRank
    @CaptureInPassing
    @End
  ]

  @startingPosition: ->
    d4: 'P'
    e7: 'p'

  @initialize()

  aiMove: -> @longestAIMove()

  Lesson = @

  class @AdvanceToFifthRank extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.AdvanceToFifthRank"

    @message: -> """
      Push your pawn deep into Black's half.

      Advance to d5.
    """

    @requiredPosition: ->
      d5: 'P'

    @initialize()

  class @CaptureInPassing extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.CaptureInPassing"

    @message: -> """
      Black tried to rush past you, two squares in one go. You may capture it "in passing" (en passant), as if it had moved only one square.

      Capture on e6.
    """

    @requiredPosition: ->
      e6: 'P'
    
    @failedPosition: ->
      d6: 'P'
    
    @retryMessage: -> """
      Push straight ahead and the moment's gone—en passant is offered for one move only.
      
      Rewind to d5 and take the pawn in passing, on e6.
    """
    
    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      En passant is allowed only on the move right after the enemy's two-square jump. Hesitate, and the chance is gone for good.
    """

    @initialize()
