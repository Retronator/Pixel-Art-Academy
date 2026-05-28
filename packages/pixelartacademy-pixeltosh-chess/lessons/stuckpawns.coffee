PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.StuckPawns extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.StuckPawns'
  @displayName: -> "Stuck pawns"

  @category: -> Chess.Lessons.Categories.Pawn

  @steps: -> [
    @AdvanceOneSquare
    @KeepGoing
    @PawnsStuck
  ]

  @startingPosition: ->
    d2: 'P'
    d7: 'p'

  @initialize()

  aiMove: -> @shortestAIMove()

  Lesson = @

  class @AdvanceOneSquare extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.AdvanceOneSquare"

    @message: -> """
      March your pawn up the board.
    """

    @requiredPosition: ->
      d2: null

    @initialize()

  class @KeepGoing extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.KeepGoing"

    @message: -> """
      Keep going.
    """

    @initialize()

    completed: -> not @gameState().getLegalMoves().length

  class @PawnsStuck extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.PawnsStuck"

    @message: -> """
      Now the pawns stand face to face. Neither can move!

      A pawn can't capture straight ahead, so two pawns meeting head-on lock each other completely.

      Try to advance: there's nowhere to go.
    """

    @initialize()
