PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.Check extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.Check'
  @displayName: -> "Check"

  @category: -> Chess.Lessons.Categories.King

  @steps: -> [
    @EscapeCheck
    @End
  ]

  @startingPosition: ->
    e4: 'K'
    e8: 'r'
    d8: 'k'

  @initialize()
  
  aiMove: -> @lessonManager.gameState().aiMove()

  Lesson = @

  class @EscapeCheck extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.EscapeCheck"

    @message: -> """
      The black rook attacks your king straight down the file. An attack on the king has a special name: check. You can never ignore it.

      Move your king off the file, out of check.
    """

    @initialize()

    completed: ->
      gameState = @gameState()
      kingSquare = gameState.occupiedSquaresOfColor(Chess.Piece.Colors.White)[0]
      kingSquare.fileIndex isnt Chess.Square.e1.fileIndex

    markup: -> [
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
