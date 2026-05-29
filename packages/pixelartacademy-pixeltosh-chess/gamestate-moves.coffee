PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

_knightOffsets = [
  [1, 2]
  [2, 1]
  [2, -1]
  [1, -2]
  [-1, -2]
  [-2, -1]
  [-2, 1]
  [-1, 2]
]

_diagonalDirections = [
  [1, 1]
  [1, -1]
  [-1, -1]
  [-1, 1]
]

_straightDirections = [
  [1, 0]
  [0, -1]
  [-1, 0]
  [0, 1]
]

_allDirections = _diagonalDirections.concat _straightDirections

class Chess.GameState extends Chess.GameState
  _getLegalPawnMovesFromSquare: (square) ->
    piece = @getPieceAtSquare square
    direction = if piece.color is Chess.Piece.Colors.White then 1 else -1

    moves = []

    nextSquare = Chess.Square[square.fileIndex][square.rankIndex + direction]

    if nextSquare and not @isSquareOccupied nextSquare
      moves.push nextSquare

      homeRank = if piece.color is Chess.Piece.Colors.White then 1 else 6

      if square.rankIndex is homeRank
        doubleSquare = Chess.Square[square.fileIndex][square.rankIndex + 2 * direction]

        if doubleSquare and not @isSquareOccupied doubleSquare
          moves.push doubleSquare

    leftCaptureSquare = Chess.Square[square.fileIndex - 1]?[square.rankIndex + direction]

    if leftCaptureSquare and @isSquareOccupiedByOpponent leftCaptureSquare
      moves.push leftCaptureSquare

    rightCaptureSquare = Chess.Square[square.fileIndex + 1]?[square.rankIndex + direction]

    if rightCaptureSquare and @isSquareOccupiedByOpponent rightCaptureSquare
      moves.push rightCaptureSquare

    if enPassantSquare = @enPassantSquare()
      if enPassantSquare.rankIndex is square.rankIndex + direction and Math.abs(enPassantSquare.fileIndex - square.fileIndex) is 1
        moves.push enPassantSquare

    moves
  
  _getLegalKnightMovesFromSquare: (square) ->
    moves = []
    
    for offset in _knightOffsets
      continue unless targetSquare = Chess.Square[square.fileIndex + offset[0]]?[square.rankIndex + offset[1]]
      continue if @isSquareOccupiedByMe targetSquare
      
      moves.push targetSquare
    
    moves

  _getLegalBishopMovesFromSquare: (square) ->
    @_getLegalSlidingPieceMovesFromSquare square, _diagonalDirections

  _getLegalRookMovesFromSquare: (square) ->
    @_getLegalSlidingPieceMovesFromSquare square, _straightDirections

  _getLegalQueenMovesFromSquare: (square) ->
    @_getLegalSlidingPieceMovesFromSquare square, _allDirections

  _getLegalSlidingPieceMovesFromSquare: (square, directions) ->
    moves = []

    for direction in directions
      distance = 1

      loop
        targetSquare = Chess.Square[square.fileIndex + direction[0] * distance]?[square.rankIndex + direction[1] * distance]
        break unless targetSquare
        break if @isSquareOccupiedByMe targetSquare

        moves.push targetSquare
        break if @isSquareOccupiedByOpponent targetSquare

        distance++

    moves

  _getLegalKingMovesFromSquare: (square) ->
    moves = []
    
    for direction in _allDirections
      targetSquare = Chess.Square[square.fileIndex + direction[0]]?[square.rankIndex + direction[1]]
      continue unless targetSquare
      continue if @isSquareOccupiedByMe targetSquare
      
      moves.push targetSquare
    
    moves
