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
      There are three ways to answer a check: move the king, capture the attacker, or block its path.
      
      This attacker stands right beside your king, and nothing defends it.

      Capture the rook on e2.
    """

    @requiredPosition: ->
      e2: 'K'
      
    @failedPosition: ->
      e2: 'r'
      e1: null

    @retryMessage: -> """
      That escapes the check too. But when the attacker is undefended and within reach, you can remove the threat for good.

      This time, take the rook on e2.
    """

    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      Capturing the attacker ends a check in the cleanest way: no attacker, no check. But take care to capture only what is undefended. Had another black piece been guarding that rook, taking it with your king would have walked him into a new check, which is forbidden.
    """

    @initialize()
