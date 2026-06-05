PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.KnightInPursuit extends Chess.Lessons.KnightCapture
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.KnightInPursuit'
  @displayName: -> "A knight in pursuit"

  @steps: -> [
    @CapturePawn
    @End
  ]

  @startingPosition: ->
    b3: 'N'
    g3: 'p'

  @initialize()

  Lesson = @

  class @CapturePawn extends Chess.Lessons.KnightCapture.CapturePawn
    @id: -> "#{Lesson.id()}.CapturePawn"

    @message: -> """
      The pawn is racing for the promotion square. You'll need to think a few moves ahead to be able to capture it.

      Plan ahead and capture the pawn.
    """

    @retryMessage: -> """
      The pawn promoted and got the best of your knight.
      
      Try again! A knight needs several moves to cross the board, so map out a route that puts you on a square the will able to defend the promotion.
    """
    
    @retryPosition: -> Lesson.startingPosition()

    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      A knight can't move quickly, but it can be in the right place in advance.
    """

    @initialize()
