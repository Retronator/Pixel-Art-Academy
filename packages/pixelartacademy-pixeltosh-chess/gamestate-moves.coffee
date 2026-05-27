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

    moves
  
  _getLegalKnightMovesFromSquare: (square) ->
    moves = []
    
    for offset in _knightOffsets
      continue unless targetSquare = Chess.Square[square.fileIndex + offset[0]]?[square.rankIndex + offset[1]]
      continue if @isSquareOccupiedByMe targetSquare
      
      moves.push targetSquare
    
    moves
