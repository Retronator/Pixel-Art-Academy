PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.QueenMovement extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.QueenMovement'
  @displayName: -> "Queen movement"

  @category: -> Chess.Lessons.Categories.Queen

  @steps: -> [
    @MoveExplanation
    @MoveTarget
    @End
  ]

  @startingPosition: ->
    d4: 'Q'

  @initialize()

  Lesson = @

  class @MoveExplanation extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.MoveExplanation"

    @message: -> """
      The queen moves like a rook and a bishop at once: along ranks, files, and diagonals, any number of squares at a time.

      Move the queen to any of the legal squares.
    """

    @requiredPosition: ->
      d4: null

    @initialize()

    onRendered: ->
      super arguments...

      @chessboard().selectSquare Chess.Square.d4

    markup: -> [
      legalMoves: true
      arrows: [
        from: Chess.Square.d4
        to: Chess.Square.d8
      ,
        from: Chess.Square.d4
        to: Chess.Square.h8
      ,
        from: Chess.Square.d4
        to: Chess.Square.h4
      ,
        from: Chess.Square.d4
        to: Chess.Square.g1
      ,
        from: Chess.Square.d4
        to: Chess.Square.d1
      ,
        from: Chess.Square.d4
        to: Chess.Square.a1
      ,
        from: Chess.Square.d4
        to: Chess.Square.a4
      ,
        from: Chess.Square.d4
        to: Chess.Square.a7
      ]
    ]

  class @MoveTarget extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.MoveTarget"

    @message: -> """
      Keep moving the queen until you reach the target.
    """

    @requiredPosition: ->
      c2: 'Q'

    @initialize()

    markup: -> [
      target:
        position: Chess.Square.c2
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      The queen is the most powerful piece on the board. From the center she reaches twenty-seven squares, more than any other piece.
      
      She shares one weakness with her parents, though: like the rook and the bishop, she cannot jump.
    """

    @initialize()
