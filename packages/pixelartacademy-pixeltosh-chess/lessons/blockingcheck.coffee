PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.BlockingCheck extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.BlockingCheck'
  @displayName: -> "Blocking the check"

  @category: -> Chess.Lessons.Categories.King

  @steps: -> [
    @BlockAttack
    @End
  ]

  @startingPosition: ->
    e1: 'K'
    d2: 'R'
    e4: 'r'
    e8: 'k'

  @initialize()
  
  aiMove: -> @randomAIMoveByPiece Chess.Piece.Types.King

  Lesson = @

  class @BlockAttack extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.BlockAttack"

    @message: -> """
      Here is the third answer to a check. This attacker is too far to capture, but you need not run from it.

      Block the check: slide your rook into the line of fire, onto e2.
    """

    @requiredPosition: ->
      e2: 'R'
      
    @failedPosition: ->
      e1: null

    @retryMessage: -> """
      Moving the king works as well. But you have a piece that can step in and shield him.

      This time, block the attack: put your rook between the king and the enemy rook, on e4.
    """

    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      Blocking shields the king with a piece of your own, breaking the attacker's line.
      It works only against the rook, bishop, and queen, since their power travels in a straight line.
      A knight's check can never be blocked, because the knight leaps over everything.
    """

    @initialize()
