PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.PawnsStrongerTogether extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.PawnsStrongerTogether'
  @displayName: -> "Pawns are stronger together"

  @category: -> Chess.Lessons.Categories.Pawn

  @steps: -> [
    @Start
    @Progress
    @End
  ]

  @startingPosition: ->
    d3: 'P'
    e4: 'P'
    d6: 'p'

  @initialize()

  aiMove: -> @randomAICapture() or @randomAIMove()

  Lesson = @

  class @Start extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.Start"

    @message: -> """
      A lone pawn marching forward is easy to stop. Two pawns side by side are not.

      Bring your d-pawn into line. Push from d3 to d4.
    """

    @retryMessage: -> """
      That sends the pawn forward alone and undefended. Black can just take it.
      
      Side by side, your pawns are ready to capture anything that gets in front of them.

      Rewind and push d3 to d4 instead.
    """

    @requiredPosition: ->
      d4: 'P'

    @failedPosition: ->
      e5: 'P'

    @initialize()

  class @Progress extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.Progress"

    @message: -> """
      Your d-pawn is now blocked head-on, but you have an attacker that can take care of it, if wanted.

      Capture the black pawn with your e-pawn, or move past it.
    """

    @requiredPosition: ->
      e4: null

    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      A lone pawn can't outmaneuver a well-placed pair.
    """

    @initialize()
