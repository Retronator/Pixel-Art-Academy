PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.RookNeverTires extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.RookNeverTires'
  @displayName: -> "The rook never tires"

  @category: -> Chess.Lessons.Categories.Rook

  @steps: -> [
    @ReachCenter
    @End
  ]

  @startingPosition: ->
    e4: 'R'

  @initialize()

  Lesson = @

  class @ReachCenter extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.ReachCenter"

    @message: -> """
      Remember how a knight on the rim is grim? Let's see if a rook suffers the same fate.
      
      From the center, your rook already commands fourteen squares, a whole rank and a whole file at once.

      Now banish it to the corner. Send it to a1.
    """

    @requiredPosition: ->
      a1: 'R'

    @initialize()

    onRendered: ->
      super arguments...

      @chessboard().selectSquare Chess.Square.e4

    markup: -> [
      legalMoves: @positionAchieved e4: 'R'
      target:
        position: Chess.Square.a1
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Still fourteen!

      A knight in the corner reaches two squares; in the center, eight. The rook reaches the same fourteen wherever it stands.
      
      Park a rook anywhere with an open line and it is ready to strike.
    """

    @initialize()

    onRendered: ->
      super arguments...

      @chessboard().selectSquare Chess.Square.a1

    markup: -> [
      legalMoves: true
    ]
