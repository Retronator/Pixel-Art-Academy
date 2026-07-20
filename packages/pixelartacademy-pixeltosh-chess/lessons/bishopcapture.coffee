PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.BishopCapture extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.BishopCapture'
  @displayName: -> "Bishop capture"

  @category: -> Chess.Lessons.Categories.Bishop

  @steps: -> [
    @CapturePawn
    Chess.Lessons.DefaultEndStep
  ]

  @startingPosition: ->
    d4: 'B'
    f6: 'p'

  @initialize()
  
  aiMove: -> @randomAICapture() or @randomAIMove()

  Lesson = @

  class @CapturePawn extends Chess.Lessons.CapturePawn
    @id: -> "#{Lesson.id()}.CapturePawn"

    @message: -> """
      A bishop can capture any opponent piece it can reach.

      Capture the pawn on f6.
    """

    @initialize()
