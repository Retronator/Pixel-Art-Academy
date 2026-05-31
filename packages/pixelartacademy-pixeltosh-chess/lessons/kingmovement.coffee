PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.KingMovement extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.KingMovement'
  @displayName: -> "King movement"

  @category: -> Chess.Lessons.Categories.King

  @steps: -> [
    @MoveExplanation
    @MoveTarget
    @End
  ]

  @startingPosition: ->
    d4: 'K'

  @initialize()

  Lesson = @

  class @MoveExplanation extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.MoveExplanation"

    @message: -> """
      The king has arrived!

      Every piece you have met so far, the pawn, knight, bishop, rook, and queen, serves one purpose: to guard this piece, or to hunt the enemy's.

      The king moves one square in any direction. Move him to any of the legal squares.
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
        to: Chess.Square.d5
      ,
        from: Chess.Square.d4
        to: Chess.Square.e5
      ,
        from: Chess.Square.d4
        to: Chess.Square.e4
      ,
        from: Chess.Square.d4
        to: Chess.Square.e3
      ,
        from: Chess.Square.d4
        to: Chess.Square.d3
      ,
        from: Chess.Square.d4
        to: Chess.Square.c3
      ,
        from: Chess.Square.d4
        to: Chess.Square.c4
      ,
        from: Chess.Square.d4
        to: Chess.Square.c5
      ]
    ]

  class @MoveTarget extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.MoveTarget"

    @message: -> """
      Keep moving the king until you reach the target.
    """

    @requiredPosition: ->
      f7: 'K'

    @initialize()

    markup: -> [
      target:
        position: Chess.Square.f7
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      The king reaches every square around him, just like the queen, but only one step at a time. He is the slowest piece on the board. Because he cannot run, you must think ahead to keep him out of trouble.
    """

    @initialize()
