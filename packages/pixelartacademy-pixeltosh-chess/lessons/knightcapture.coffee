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

  class @CapturePawn extends Chess.Lessons.CapturePawn
    @id: -> "#{Lesson.id()}.CapturePawn"

    @message: -> """
      A knight will capture an opponent piece it can jump on.

      Capture the pawn.
    """

    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      Because the knight jumps, nothing can block its attack. The only defense is to move the target, or have another piece ready to capture the knight in return.
    """

    @initialize()
