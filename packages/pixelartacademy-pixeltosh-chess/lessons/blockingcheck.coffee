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
      Here is the third answer to a check, besides moving away or capturing the attacker.

      Block the check: move your rook onto e2, to cut the line of attack.
    """

    @requiredPosition: ->
      e2: 'R'
      
    @failedPosition: ->
      e1: null

    @retryMessage: -> """
      Moving the king works too, but you have a piece that can answer with blocking.

      Try to block the attack: put your rook on e4 between the king and the enemy rook.
    """

    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      Blocking shields the king with a piece of your own, breaking the attacker's line.
      It works only against the rook, bishop, and queen, since their attacks travel in straight lines.
      A knight's check can never be blocked, because the knight can jump over pieces.
    """

    @initialize()
