PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.CapturingAttacker extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.CapturingAttacker'
  @displayName: -> "Capturing the attacker"

  @category: -> Chess.Lessons.Categories.King

  @steps: -> [
    @RookMove
    @CaptureAttacker
    @End
  ]

  @startingGameState: ->
    state = Chess.GameState.fromPosition
      e1: 'K'
      a2: 'r'
      e8: 'k'
    
    state.setTurn Chess.Piece.Colors.Black
    
    state
  
  @initialize()
  
  aiMove: ->
    gameState = @lessonManager.gameState()
    
    if gameState.getPieceAtSquare(Chess.Square.a2)?.type is Chess.Piece.Types.Rook
      new Chess.Move Chess.Square.a2, Chess.Square.e2
    
    else
      @lessonManager.gameState().aiMove()

  Lesson = @

  class @RookMove extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.RookMove"
    
    @initialize()
    
    @requiredPosition: ->
      e2: 'r'

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

      Note that if the attacker was defended by another black piece, the king couldn't take it as that would walk him into check.
    """

    @initialize()
