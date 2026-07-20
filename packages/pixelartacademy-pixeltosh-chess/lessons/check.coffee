PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.Check extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.Check'
  @displayName: -> "Check"

  @category: -> Chess.Lessons.Categories.King

  @steps: -> [
    @RookMove
    @EscapeCheck
    @End
  ]

  @startingGameState: ->
    state = Chess.GameState.fromPosition
      e4: 'K'
      h8: 'r'
      d8: 'k'
    
    state.setTurn Chess.Piece.Colors.Black
    
    state

  @initialize()
  
  aiMove: ->
    gameState = @lessonManager.gameState()
  
    if gameState.getPieceAtSquare(Chess.Square.h8)?.type is Chess.Piece.Types.Rook
      new Chess.Move Chess.Square.h8, Chess.Square.e8
      
    else
      @lessonManager.gameState().aiMove()

  Lesson = @
  
  class @RookMove extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.RookMove"
    
    @initialize()
    
    @requiredPosition: ->
      e8: 'r'

  class @EscapeCheck extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.EscapeCheck"

    @message: -> """
      The black rook attacks your king down the file. An attack on the king has a special name: check. You can never ignore it.

      Move your king off the file, out of check.
    """

    @initialize()
    
    constructor: ->
      super arguments...

      @showMarkup = new ReactiveField false
    
    onCreated: ->
      super arguments...
      
      await _.waitForSeconds 0.5
      @showMarkup true

    completed: ->
      gameState = @gameState()
      kingSquare = gameState.occupiedSquaresOfColor(Chess.Piece.Colors.White)[0]
      kingSquare.fileIndex isnt Chess.Square.e1.fileIndex

    markup: ->
      return unless @showMarkup()

      [
        arrow:
          from: Chess.Square.e8
          to: Chess.Square.e5
      ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      Check is a direct threat to the king himself, and every check must be answered at once. Stepping away is one answer.
      
      There are two others: blocking and capturing.
    """

    @initialize()
