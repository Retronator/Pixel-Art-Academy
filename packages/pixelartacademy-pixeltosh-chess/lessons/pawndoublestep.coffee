PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.PawnDoubleStep extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.PawnDoubleStep'
  @displayName: -> "Pawn double-step"

  @category: -> Chess.Lessons.Categories.Pawn

  @steps: -> [
    @DoubleStepExplanation
    @SingleStepAfterMoving
    @End
  ]

  @startingPosition: ->
    D2: 'P'

  @initialize()

  Lesson = @

  class @DoubleStepExplanation extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.DoubleStepExplanation"

    @message: -> """
      From its very first move, a pawn may advance one or two squares.

      Move the pawn from D2 to D4.
    """

    @requiredPosition: ->
      D4: 'P'
      
    @retryMessage: -> """
      One square is always legal—but you just spent your one-time jump to go half as far.
      
      Let's rewind and use it properly: D2 straight to D4.
    """
    
    @failedPosition: ->
      D3: 'P'

    @initialize()

    onRendered: ->
      super arguments...

      @chessboard().selectSquare Chess.Square.D2

    markup: -> [
      legalMoves: true
    ]

  class @SingleStepAfterMoving extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.SingleStepAfterMoving"

    @message: -> """
      Now that it has moved, the pawn advances just one square at a time.
    """

    @requiredPosition: ->
      D5: 'P'

    @initialize()

    onRendered: ->
      super arguments...

      @chessboard().selectSquare Chess.Square.D4

    markup: -> [
      legalMoves: true
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      The two-square jump is a one-time offer—only on a pawn's very first move.
    """

    @initialize()
