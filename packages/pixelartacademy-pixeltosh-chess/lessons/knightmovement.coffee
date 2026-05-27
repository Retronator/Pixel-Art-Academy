PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.KnightMovement extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.KnightMovement'
  @displayName: -> "Knight movement"
  
  @category: -> Chess.Lessons.Categories.Knight

  @steps: -> [
    @MoveExplanation
    @MoveTarget
    Chess.Lessons.DefaultEndStep
  ]
  
  @startingPosition: ->
    D4: 'N'
  
  @initialize()

  Lesson = @
  
  class @MoveExplanation extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.MoveExplanation"
    
    @message: -> """
      The knight moves in an L-shape: two squares in one direction, then one square to either side.

      Move the knight to any of the legal squares.
    """
    
    @requiredPosition: ->
      D4: null
    
    @initialize()
    
    onRendered: ->
      super arguments...
      
      @chessboard().selectSquare Chess.Square.D4
    
    markup: -> [
      legalMoves: true
      arrow:
        from: Chess.Square.D4
        to: Chess.Square.E2
    ]

  class @MoveTarget extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.MoveTarget"
    
    @message: -> """
      Keep moving the knight until you reach the target.
    """
    
    @requiredPosition: ->
      B2: 'N'
      
    @initialize()
    
    markup: -> [
      target:
        position: Chess.Square.B2
    ]
