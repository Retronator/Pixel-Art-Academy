PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.PawnCapture extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.PawnCapture'
  @displayName: -> "Pawn capture"

  @category: -> Chess.Lessons.Categories.Pawn

  @steps: -> [
    @CaptureDirections
    @CapturePawn
    @End
  ]

  @startingPosition: ->
    e3: 'P'
    d6: 'p'

  @initialize()

  aiMove: -> @randomAIMove()

  Lesson = @

  class @CaptureDirections extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.CaptureDirections"

    @message: -> """
      Pawns march straight ahead, but they capture diagonally—one square forward, to either side.

      Advance your pawn to e4.
    """

    @requiredPosition: ->
      e4: 'P'

    @initialize()

    markup: -> [
      arrows: [
        from: Chess.Square.e3
        to: Chess.Square.d4
      ,
        from: Chess.Square.e3
        to: Chess.Square.f4
      ]
    ]

  class @CapturePawn extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.CapturePawn"

    @message: -> """
      A black pawn has stepped onto your diagonal. Take it!

      Capture on d5.
    """

    @requiredPosition: ->
      d5: 'P'

    @failedPosition: ->
      e5: 'P'
    
    @retryMessage: -> """
      A pawn captures to the side, not straight ahead. You walked right past the prize.

      Back to e4: this time, step onto d5 and take it.
    """
    
    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      The pawn is the only piece that moves one way and captures another.
    """

    @initialize()
