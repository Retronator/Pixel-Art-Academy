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
    d2: 'P'

  @initialize()

  Lesson = @

  class @DoubleStepExplanation extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.DoubleStepExplanation"

    @message: -> """
      On its first move, a pawn may advance one or two squares.

      Move the pawn from d2 to d4.
    """

    @requiredPosition: ->
      d4: 'P'
      
    @retryMessage: -> """
      One square is always legal, but you just spent your one-time jump to go half as far.
      
      Let's rewind and use this special move: d2 straight to d4.
    """
    
    @failedPosition: ->
      d3: 'P'

    @initialize()

    onRendered: ->
      super arguments...

      @chessboard().selectSquare Chess.Square.d2

    markup: -> [
      legalMoves: true
    ]

  class @SingleStepAfterMoving extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.SingleStepAfterMoving"

    @message: -> """
      Now that it has moved, the pawn advances just one square at a time.
    """

    @requiredPosition: ->
      d5: 'P'

    @initialize()

    onRendered: ->
      super arguments...

      @chessboard().selectSquare Chess.Square.d4

    markup: -> [
      legalMoves: true
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      The two-square jump is a one-time offer. You can only perform it from its home square.
    """

    @initialize()
