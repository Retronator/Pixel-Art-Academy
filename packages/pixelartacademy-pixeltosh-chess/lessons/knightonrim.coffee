PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.KnightOnRim extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.KnightOnRim'
  @displayName: -> "A knight on the rim"

  @category: -> Chess.Lessons.Categories.Knight

  @steps: -> [
    @SideReach
    @MoveToCenter
    @End
  ]

  @startingPosition: ->
    a3: 'N'

  @initialize()

  Lesson = @

  class @SideReach extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.SideReach"

    @message: -> """
      Placed on the edge, this knight reaches only four squares.
      
      Move it somewhere it can do more.
    """
    
    @requiredPosition: ->
      a3: null
      
    @initialize()

    onRendered: ->
      super arguments...

      @chessboard().selectSquare Chess.Square.a3


    markup: -> [
      legalMoves: true
    ]

  class @MoveToCenter extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.MoveToCenter"

    @message: -> """
      Keep going until the knight has its full range.
    """

    @initialize()
    
    onRendered: ->
      super arguments...
      
      @chessboard().selectSquare @gameState().occupiedSquares()[0]

    completed: -> @gameState().getLegalMoves().length is 8
    
    markup: -> [
      legalMoves: true
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!
      
      From an active square the knight reaches eight squares—twice as many as on the rim.
      
      There's a saying: "a knight on the rim is grim."
    """

    @initialize()

    onRendered: ->
      super arguments...

      @chessboard().selectSquare @gameState().occupiedSquares()[0]

    markup: -> [
      legalMoves: true
    ]
