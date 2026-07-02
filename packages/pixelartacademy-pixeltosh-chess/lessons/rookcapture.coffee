PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.RookCapture extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.RookCapture'
  @displayName: -> "Rook capture"

  @category: -> Chess.Lessons.Categories.Rook

  @steps: -> [
    @CapturePawn
    Chess.Lessons.DefaultEndStep
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
