PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.BishopMovement extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.BishopMovement'
  @displayName: -> "Bishop movement"

  @category: -> Chess.Lessons.Categories.Bishop

  @steps: -> [
    @MoveExplanation
    @MoveTarget
    @End
  ]

  @startingPosition: ->
    D4: 'B'

  @initialize()

  Lesson = @

  class @MoveExplanation extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.MoveExplanation"

    @message: -> """
      The bishop moves diagonally, any number of squares at a time.

      Move the bishop to any of the legal squares.
    """

    @requiredPosition: ->
      D4: null

    @initialize()

    onRendered: ->
      super arguments...

      @chessboard().selectSquare Chess.Square.D4

    markup: -> [
      legalMoves: true
      arrows: [
        from: Chess.Square.D4
        to: Chess.Square.H8
      ,
        from: Chess.Square.D4
        to: Chess.Square.A7
      ,
        from: Chess.Square.D4
        to: Chess.Square.A1
      ,
        from: Chess.Square.D4
        to: Chess.Square.G1
      ]
    ]

  class @MoveTarget extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.MoveTarget"

    @message: -> """
      Keep moving the bishop until you reach the target.
    """

    @initialize()
    
    completed: ->
      return unless gameState = @gameState()
      return unless bishopSquare = gameState.occupiedSquares()[0]
      
      manhattanDistance = Math.abs(bishopSquare.fileIndex) + Math.abs(bishopSquare.rankIndex - 3)
      manhattanDistance is 1
    
    markup: -> [
      target:
        position: Chess.Square.A4
    ]
  
  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"
    
    @message: -> """
      As you might have guessed, this bishop can't reach the target. It's confined to the dark squares, so we call it the dark-squared bishop.
      
      Each player starts with both a light-squared and a dark-squared bishop. Only together can they reach any target.
    """
    
    @initialize()
    
    markup: -> [
      target:
        position: Chess.Square.A4
    ]
