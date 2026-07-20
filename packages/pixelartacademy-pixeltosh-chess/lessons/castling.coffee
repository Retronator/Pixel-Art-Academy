PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.Castling extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.Castling'
  @displayName: -> "Castling"

  @category: -> Chess.Lessons.Categories.King

  @steps: -> [
    @CastleKingside
    @End
  ]

  @startingPosition: ->
    e1: 'K'
    h1: 'R'
    e8: 'k'
    f2: 'P'
    g2: 'P'
    h2: 'P'

  @startingGameState: ->
    pieces = {}

    for squareName, pieceLetter of @startingPosition()
      pieces[squareName.toUpperCase()] = pieceLetter

    new Chess.GameState _.extend Chess.GameState.getEmptyData(),
      pieces: pieces
      castling:
        whiteShort: true
        whiteLong: false
        blackShort: false
        blackLong: false

  @initialize()

  Lesson = @

  class @CastleKingside extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.CastleKingside"

    @message: -> """
      The king in the center gets quickly exposed to checks. A special move can help you defend: castling. In one move, the king moves two squares toward a rook, and the rook jumps over it.

      Castle: move your king to g1.
    """

    @requiredPosition: ->
      g1: 'K'
      
    @failedPosition: ->
      f1: 'K'
    
    @retryMessage: -> """
      Castling is initiated by moving two squares at once. It doesn't work when moving one-by-one.

      Castle in one move: slide the king all the way to g1.
    """
    
    @initialize()

    markup: -> [
      arrow:
        from: Chess.Square.e1
        to: Chess.Square.g1
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      Castling is allowed only if neither the king nor that rook has moved yet. The king must also not be in check or travel on attacked squares.
      
      You can castle the other way as well, toward the queen-side rook.
    """

    @initialize()
