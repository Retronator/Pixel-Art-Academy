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

  isSquareOccupied: (square) -> @data.pieces[square.name]
  
  isSquareOccupiedByMe: (square) ->
    return unless piece = @getPieceAtSquare square
    piece.color is @turn()

  isSquareOccupiedByOpponent: (square) ->
    return unless piece = @getPieceAtSquare square
    opponentColor = if @data.turn is 'white' then Chess.Piece.Colors.Black else Chess.Piece.Colors.White
    piece.color is opponentColor

  getPieceAtSquare: (square) -> Chess.Piece.fromLetter @data.pieces[square.name]

  hasPieceAtSquare: (piece, square) -> @data.pieces[square.name] is piece?.letter

  hasSamePiecePlacementAs: (gameState) -> EJSON.equals @data.pieces, gameState.data.pieces

  getLegalMovesFromSquare: (square) ->
    try
      moves = ChessEngine.moves @data
      return [] unless moves[square.name]

      Chess.Square[squareName] for squareName in moves[square.name]

    catch
      # The state is not a valid chess position so we have to calculate the moves ourselves.
      return [] unless piece = @getPieceAtSquare square

      switch piece.type
        when Chess.Piece.Types.Pawn then @_getLegalPawnMovesFromSquare square
        when Chess.Piece.Types.Knight then @_getLegalKnightMovesFromSquare square
        when Chess.Piece.Types.Bishop then @_getLegalBishopMovesFromSquare square
        when Chess.Piece.Types.Rook then @_getLegalRookMovesFromSquare square
        when Chess.Piece.Types.Queen then @_getLegQueenMovesFromSquare square
        when Chess.Piece.Types.King then @_getLegalKingMovesFromSquare square

  applyMove: (move) ->
    try
      new @constructor ChessEngine.move @data, move.from.name, move.to.name

    catch
      # The state is not a valid chess position so we have to calculate the new state ourselves.
      data = _.cloneDeep @data
      data.pieces[move.to.name] = data.pieces[move.from.name]
      delete data.pieces[move.from.name]
      new @constructor data
