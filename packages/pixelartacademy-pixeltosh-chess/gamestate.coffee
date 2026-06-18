PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

ChessEngine = require 'js-chess-engine'

class Chess.GameState
  @getEmptyData: ->
    turn: 'white'
    pieces: {}
    castling: {}
    halfMove: 0
    fullMove: 1
    
  @fromPosition: (position) ->
    pieces = {}
    
    for squareName, pieceLetter of position
      pieces[squareName.toUpperCase()] = pieceLetter
    
    new @ _.extend @getEmptyData(), {pieces}

  constructor: (@data) ->
  
  getPositionKey: ->
    return @_positionKey if @_positionKey
    
    pieces = ("#{squareName}:#{pieceLetter}" for squareName, pieceLetter of @data.pieces)
    pieces.sort()
    
    castling = []
    castling.push "#{key}:#{value}" for key, value of @data.castling
    castling.sort()
    
    @_positionKey = [
      pieces.join ','
      @data.turn
      castling.join ','
      @data.enPassant or ''
    ].join '|'

  turn: -> if @data.turn is 'white' then Chess.Piece.Colors.White else Chess.Piece.Colors.Black

  setTurn: (color) ->
    @data.turn = color.toLowerCase()
    @_engineMoves = null

  check: -> @data.check

  checkMate: -> @data.checkMate

  staleMate: -> @data.staleMate

  finished: -> @data.isFinished
  
  halfMove: -> @data.halfMove

  enPassantSquare: -> Chess.Square[@data.enPassant] if @data.enPassant

  occupiedSquares: -> Chess.Square[squareName] for squareName of @data.pieces

  occupiedSquaresOfColor: (color) ->
    _.filter @occupiedSquares(), (square) => @getPieceAtSquare(square).color is color
    
  occupiedSquaresByPiecesOfColor: (pieceType, color) ->
    _.filter @occupiedSquares(), (square) =>
      piece = @getPieceAtSquare square
      piece.type is pieceType and piece.color is color

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

  getPieces: -> (Chess.Piece.fromLetter pieceLetter for squareName, pieceLetter of @data.pieces)
  
  getPiecesOfColor: (color) -> _.filter @getPieces(), (piece) => piece.color is color
  
  getPiecesOfTypeAndColor: (pieceType, color) -> _.filter @getPieces(), (piece) => piece.type is pieceType and piece.color is color

  hasSamePiecePlacementAs: (gameState) -> EJSON.equals @data.pieces, gameState.data.pieces

  getLegalDestinationsFromSquare: (square) ->
    if engineMoves = @_getEngineMoves()
      return [] unless engineMoves[square.engineName]

      Chess.Square[squareName] for squareName in engineMoves[square.engineName]

    else
      # The state is not a valid chess position so we have to calculate the moves ourselves.
      return [] unless piece = @getPieceAtSquare square

      switch piece.type
        when Chess.Piece.Types.Pawn then @_getLegalPawnMovesFromSquare square
        when Chess.Piece.Types.Knight then @_getLegalKnightMovesFromSquare square
        when Chess.Piece.Types.Bishop then @_getLegalBishopMovesFromSquare square
        when Chess.Piece.Types.Rook then @_getLegalRookMovesFromSquare square
        when Chess.Piece.Types.Queen then @_getLegalQueenMovesFromSquare square
        when Chess.Piece.Types.King then @_getLegalKingMovesFromSquare square

  getLegalMoves: ->
    return @_moves if @_moves

    @_moves = []

    if engineMoves = @_getEngineMoves()
      for fromSquareName, toSquareNames of engineMoves
        for toSquareName in toSquareNames
          @_moves.push new Chess.Move Chess.Square[fromSquareName], Chess.Square[toSquareName]

    else
      for fromSquare in @occupiedSquaresOfColor @turn()
        for toSquare in @getLegalDestinationsFromSquare fromSquare
          @_moves.push new Chess.Move fromSquare, toSquare

    @_moves

  aiMove: (level) ->
    Chess.Move.fromEngine ChessEngine.aiMove @data, level

  _getEngineMoves: ->
    return @_engineMoves if @_engineMoves?
    
    try
      @_engineMoves = ChessEngine.moves @data
      
    catch error
      @_engineMoves = false
  
  applyMove: (move) ->
    try
      data = ChessEngine.move @data, move.from.engineName, move.to.engineName

      # JS Chess Engine automatically promotes pawns to queens, so we have to override the piece.
      if move.promotionPieceType
        piece = @getPieceAtSquare move.from
        data.pieces[move.to.engineName] = Chess.Piece.getLetter piece.color, move.promotionPieceType

      # Stateless call to move doesn't update checkmate and stalemate automatically, so we have to do it ourselves.
      unless _.keys(ChessEngine.moves(data)).length
        if data.check
          data.checkMate = true
          
        else
          data.staleMate = true
          
        data.isFinished = true
      
      new @constructor data

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
      if piece.type is Chess.Piece.Types.Pawn and move.to.rankIndex in [0, 7]
        pieceType = move.promotionPieceType or Chess.Piece.Types.Queen
        data.pieces[move.to.engineName] = Chess.Piece.getLetter piece.color, pieceType

      else
        data.pieces[move.to.engineName] = data.pieces[move.from.engineName]

      delete data.pieces[move.from.engineName]

      # Add en passant possibility.
      if piece.type is Chess.Piece.Types.Pawn and Math.abs(move.to.rankIndex - move.from.rankIndex) is 2
        enPassantRankIndex = (move.from.rankIndex + move.to.rankIndex) / 2
        data.enPassant = Chess.Square[move.from.fileIndex][enPassantRankIndex].engineName

      # Change side.
      data.turn = if data.turn is 'white' then 'black' else 'white'

      new @constructor data
    
  startPromotion: (move) ->
    # We create a simple copy with the pawn moved to the last rank.
    data = _.cloneDeep @data
    
    data.pieces[move.to.engineName] = data.pieces[move.from.engineName]
    delete data.pieces[move.from.engineName]
    
    new @constructor data

  hasInsufficientMaterial: ->
    pieces = {}

    for color in Chess.Piece.AllColors
      pieces[color] = {}
  
      for pieceType in Chess.Piece.AllTypes
        pieces[color][pieceType] = @occupiedSquaresByPiecesOfColor pieceType, color

    # Insufficient material only applies to legal positions with both kings on the board.
    return unless pieces[Chess.Piece.Colors.White][Chess.Piece.Types.King].length
    return unless pieces[Chess.Piece.Colors.Black][Chess.Piece.Types.King].length

    # Pawns, rooks, and queens can always provide mating material.
    for color in Chess.Piece.AllColors
      return if pieces[color][Chess.Piece.Types.Pawn].length
      return if pieces[color][Chess.Piece.Types.Rook].length
      return if pieces[color][Chess.Piece.Types.Queen].length

    minorPieces = []

    for color in Chess.Piece.AllColors
      for square in pieces[color][Chess.Piece.Types.Bishop]
        minorPieces.push {type: Chess.Piece.Types.Bishop, square}

      for square in pieces[color][Chess.Piece.Types.Knight]
        minorPieces.push {type: Chess.Piece.Types.Knight}

    # A single bishop or knight cannot force a checkmate.
    return true if minorPieces.length <= 1
    
    # Same-colored bishops cannot force a checkmate.
    if minorPieces.length is 2 and minorPieces[0].type is Chess.Piece.Types.Bishop and minorPieces[1].type is Chess.Piece.Types.Bishop
      return minorPieces[0].square.color is minorPieces[1].square.color

    false
