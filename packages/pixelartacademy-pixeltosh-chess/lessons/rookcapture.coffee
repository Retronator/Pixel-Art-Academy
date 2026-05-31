PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.RookCapture extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.RookCapture'
  @displayName: -> "Rook capture"

  @category: -> Chess.Lessons.Categories.Rook

  @steps: -> [
    @CapturePawn
    @End
  ]

  @startingPosition: ->
    d2: 'R'
    d6: 'p'

  @initialize()
  
  aiMove: -> @randomAICapture() or @randomAIMove()

  Lesson = @

  class @CapturePawn extends Chess.Lessons.CapturePawn
    @id: -> "#{Lesson.id()}.CapturePawn"

    @message: -> """
      The rook captures by sliding onto an enemy in its path.

      Capture the pawn.
    """

    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      On an open line nothing escapes a rook except a piece that blocks the way.
    """

    @initialize()
