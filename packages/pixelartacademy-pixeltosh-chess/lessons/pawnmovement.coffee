PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.PawnMovement extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.PawnMovement'
  @displayName: -> "Pawn movement"
  
  @category: -> Chess.Lessons.Categories.Pawn

  @steps: -> [
    @MoveExplanation
    @MoveTarget
    @End
  ]
  
  @startingPosition: ->
    d4: 'P'
  
  @initialize()

  Lesson = @
  
  class @MoveExplanation extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.MoveExplanation"
    
    @message: -> """
      The pawn advances one square at a time.

      Move the pawn from d4 to d5.
    """
    
    @requiredPosition: ->
      d5: 'P'
    
    @initialize()
    
    onRendered: ->
      super arguments...
      
      @chessboard().selectSquare Chess.Square.d4
    
    markup: -> [
      legalMoves: true
      arrow:
        from: Chess.Square.d4
        to: Chess.Square.d5
    ]

  class @MoveTarget extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.MoveTarget"
    
    @message: -> """
      Keep advancing the pawn until you reach the target.
    """
    
    @requiredPosition: ->
      d7: 'P'
      
    @initialize()
    
    markup: -> [
      target:
        position: Chess.Square.d7
    ]
  
  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"
    
    @message: -> """
      Well done!

      The pawn has special moves too—find them in other lessons.
    """

    @initialize()
