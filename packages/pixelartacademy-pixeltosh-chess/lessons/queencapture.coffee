PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.QueenCapture extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.QueenCapture'
  @displayName: -> "Queen capture"

  @category: -> Chess.Lessons.Categories.Queen

  @steps: -> [
    @CapturePawn
    @End
  ]

  @startingPosition: ->
    d4: 'Q'
    g7: 'p'

  @initialize()
  
  aiMove: -> @randomAICapture() or @randomAIMove()

  Lesson = @

  class @CapturePawn extends Chess.Lessons.CapturePawn
    @id: -> "#{Lesson.id()}.CapturePawn"

    @message: -> """
      The queen captures along any of her lines, straight or diagonal.

      Capture the pawn.
    """

    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      Rook's lines and bishop's diagonals together, the queen strikes in every direction. Across an open board, few squares are safe from her.
    """

    @initialize()
