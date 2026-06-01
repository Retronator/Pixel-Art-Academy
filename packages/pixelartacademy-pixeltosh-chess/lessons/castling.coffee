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
      In the center, the king is slow and exposed. There is a special move to whisk him to safety: castling. In one move the king slides two squares toward a rook, and that rook hops over to his far side.

      Castle: move your king to g1.
    """

    @requiredPosition: ->
      g1: 'K'
      
    @failedPosition: ->
      f1: 'K'
    
    @retryMessage: -> """
      Castling is a single move, not two. The king leaps two squares at once, he does not walk there one step at a time.

      Castle in one move: send the king straight to g1.
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

      Castling is allowed only if neither the king nor that rook has moved yet, and the king is not in check, does not pass through an attacked square, and does not land on one.
      
      You can also castle the other way, toward the distant rook.
    """

    @initialize()
