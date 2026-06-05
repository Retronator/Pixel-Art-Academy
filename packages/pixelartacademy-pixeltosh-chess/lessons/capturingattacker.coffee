PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.CapturingAttacker extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.CapturingAttacker'
  @displayName: -> "Capturing the attacker"

  @category: -> Chess.Lessons.Categories.King

  @steps: -> [
    @CaptureAttacker
    @End
  ]

  @startingPosition: ->
    e1: 'K'
    e2: 'r'
    e8: 'k'

  @initialize()
  
  aiMove: -> @lessonManager.gameState().aiMove()

  Lesson = @

  class @CaptureAttacker extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.CaptureAttacker"

    @message: -> """
      There are three ways to answer a check: move the king, capture the attacker, or block the attack.
      
      This attacker stands within your king's reach, and no defender prevents you from taking it.

      Capture the rook on e2.
    """

    @requiredPosition: ->
      e2: 'K'
      
    @failedPosition: ->
      e2: 'r'
      e1: null

    @retryMessage: -> """
      That answers the check too, but since the attacker is undefended and within reach, you can make it pay the price.

      This time, take the rook on e2.
    """

    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      Note that if the attacker was defended by another black piece, the king couldn't take it as that would walked him into check.
    """

    @initialize()
