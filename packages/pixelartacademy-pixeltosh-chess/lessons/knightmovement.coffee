PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.KnightMovement extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.KnightMovement'
  @displayName: -> "Knight movement"
  
  @category: -> Chess.Lessons.Categories.Knight

  @steps: -> [
    @MoveExplanation
    @MoveTarget
    @End
  ]
  
  @startingPosition: ->
    d4: 'N'
  
  @initialize()

  Lesson = @
  
  class @MoveExplanation extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.MoveExplanation"
    
    @message: -> """
      The knight moves in an L-shape: two squares in one direction, then one square to either side.

      Move the knight to any of the legal squares.
    """
    
    @requiredPosition: ->
      d4: null
    
    @initialize()
    
    onRendered: ->
      super arguments...
      
      @chessboard().selectSquare Chess.Square.d4
    
    markup: -> [
      legalMoves: true
      arrow:
        from: Chess.Square.d4
        to: Chess.Square.e2
    ]

  class @MoveTarget extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.MoveTarget"
    
    @message: -> """
      Keep moving the knight until you reach the target.
    """
    
    @requiredPosition: ->
      b2: 'N'
      
    @initialize()
    
    markup: -> [
      target:
        position: Chess.Square.b2
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      The knight is the only piece that doesn't move in a straight line. Its crooked path makes it the trickiest piece to see coming.
    """

    @initialize()
