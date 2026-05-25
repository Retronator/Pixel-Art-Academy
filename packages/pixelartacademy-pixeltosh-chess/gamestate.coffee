PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

ChessEngine = require 'js-chess-engine'

class Chess.GameState
  @getEmptyData: ->
    turn: 'white'
    pieces: {}
    castling: {}
    halfMove: 0
    fullMove: 0

  constructor: (@data) ->

  turn: -> if @data.turn is 'white' then Chess.Piece.Colors.White else Chess.Piece.Colors.Black

  check: -> @data.check

  checkMate: -> @data.checkMate

  staleMate: -> @data.staleMate

  finished: -> @data.isFinished

  occupiedSquares: -> Chess.Square[squareName] for squareName of @data.pieces

  getPieceAtSquare: (square) -> Chess.Piece.fromLetter @data.pieces[square.name]

  hasPieceAtSquare: (piece, square) -> @data.pieces[square.name] is piece?.letter

  hasSamePiecePlacementAs: (gameState) -> EJSON.equals @data.pieces, gameState.data.pieces

  getLegalMovesFromSquare: (square) ->
    moves = ChessEngine.moves @data
    return [] unless moves[square.name]

    Chess.Square[squareName] for squareName in moves[square.name]
