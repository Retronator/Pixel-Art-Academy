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
    try
      @_engineMoves = ChessEngine.moves @data

  turn: -> if @data.turn is 'white' then Chess.Piece.Colors.White else Chess.Piece.Colors.Black
  setTurn: (color) -> @data.turn = color.toLowerCase()

  check: -> @data.check

  checkMate: -> @data.checkMate

  staleMate: -> @data.staleMate

  finished: -> @data.isFinished

  enPassantSquare: -> Chess.Square[@data.enPassant] if @data.enPassant

  occupiedSquares: -> Chess.Square[squareName] for squareName of @data.pieces

  occupiedSquaresOfColor: (color) ->
    _.filter @occupiedSquares(), (square) => @getPieceAtSquare(square).color is color

  isSquareOccupied: (square) -> @data.pieces[square.engineName]
  
  isSquareOccupiedByMe: (square) ->
    return unless piece = @getPieceAtSquare square
    piece.color is @turn()

  isSquareOccupiedByOpponent: (square) ->
    return unless piece = @getPieceAtSquare square
    opponentColor = if @data.turn is 'white' then Chess.Piece.Colors.Black else Chess.Piece.Colors.White
    piece.color is opponentColor

  getPieceAtSquare: (square) -> Chess.Piece.fromLetter @data.pieces[square.engineName]

  hasPieceAtSquare: (piece, square) -> @data.pieces[square.engineName] is piece?.letter

  hasSamePiecePlacementAs: (gameState) -> EJSON.equals @data.pieces, gameState.data.pieces

  getLegalDestinationsFromSquare: (square) ->
    if @_engineMoves
      return [] unless @_engineMoves[square.engineName]

      Chess.Square[squareName] for squareName in @_engineMoves[square.engineName]

    else
      # The state is not a valid chess position so we have to calculate the moves ourselves.
      return [] unless piece = @getPieceAtSquare square

      switch piece.type
        when Chess.Piece.Types.Pawn then @_getLegalPawnMovesFromSquare square
        when Chess.Piece.Types.Knight then @_getLegalKnightMovesFromSquare square
        when Chess.Piece.Types.Bishop then @_getLegalBishopMovesFromSquare square
        when Chess.Piece.Types.Rook then @_getLegalRookMovesFromSquare square
        when Chess.Piece.Types.Queen then @_getLegQueenMovesFromSquare square
        when Chess.Piece.Types.King then @_getLegalKingMovesFromSquare square

  getLegalMoves: ->
    return @_moves if @_moves

    @_moves = []

    if @_engineMoves
      for fromSquareName, toSquareNames of @_engineMoves
        for toSquareName in toSquareNames
          @_moves.push new Chess.Move Chess.Square[fromSquareName], Chess.Square[toSquareName]

    else
      for fromSquare in @occupiedSquaresOfColor @turn()
        for toSquare in @getLegalDestinationsFromSquare fromSquare
          @_moves.push new Chess.Move fromSquare, toSquare

    @_moves

  applyMove: (move) ->
    try
      new @constructor ChessEngine.move @data, move.from.engineName, move.to.engineName

    catch
      # The state is not a valid chess position so we have to calculate the new state ourselves.
      data = _.cloneDeep @data
      piece = @getPieceAtSquare move.from

      # Handle en passant capture.
      delete data.enPassant

      if piece.type is Chess.Piece.Types.Pawn and move.to is @enPassantSquare()
        capturedPawnSquare = Chess.Square[move.to.fileIndex][move.from.rankIndex]
        delete data.pieces[capturedPawnSquare.engineName]

      # Move the piece to the new square.
      data.pieces[move.to.engineName] = data.pieces[move.from.engineName]
      delete data.pieces[move.from.engineName]

      # Add en passant possibility.
      if piece.type is Chess.Piece.Types.Pawn and Math.abs(move.to.rankIndex - move.from.rankIndex) is 2
        enPassantRankIndex = (move.from.rankIndex + move.to.rankIndex) / 2
        data.enPassant = Chess.Square[move.from.fileIndex][enPassantRankIndex].engineName

      # Change side.
      data.turn = if data.turn is 'white' then 'black' else 'white'

      new @constructor data
