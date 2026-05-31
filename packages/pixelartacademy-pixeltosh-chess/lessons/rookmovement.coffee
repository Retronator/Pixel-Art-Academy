PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.RookMovement extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.RookMovement'
  @displayName: -> "Rook movement"

  @category: -> Chess.Lessons.Categories.Rook

  @steps: -> [
    @MoveExplanation
    @MoveTarget
    @End
  ]

  @startingPosition: ->
    d4: 'R'

  @initialize()

  Lesson = @

  class @MoveExplanation extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.MoveExplanation"

    @message: -> """
      The rook moves in straight lines, along ranks (rows) and files (columns), any number of squares at a time.

      Move the rook to any of the legal squares.
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
        to: Chess.Square.h4
      ,
        from: Chess.Square.d4
        to: Chess.Square.a4
      ,
        from: Chess.Square.d4
        to: Chess.Square.d1
      ]
    ]

  class @MoveTarget extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.MoveTarget"

    @message: -> """
      Keep moving the rook until you reach the target.
    """

    @requiredPosition: ->
      a8: 'R'

    @initialize()

    markup: -> [
      target:
        position: Chess.Square.a8
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      The rook is a powerful long-range piece. Down an open rank (row) or file (column) it sweeps the whole length of the board in a single move.
    """

    @initialize()
