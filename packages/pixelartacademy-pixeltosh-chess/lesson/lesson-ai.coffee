AE = Artificial.Everywhere
AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lesson extends Chess.Lesson
  randomAIMove: ->
    Random.choice @_getBlackMoves()

  randomAICapture: ->
    gameState = @lessonManager.gameState()
    captureMoves = _.filter @_getBlackMoves(), (move) => gameState.isSquareOccupied move.to
    return null unless captureMoves.length

    Random.choice captureMoves

  shortestAIMove: ->
    moves = @_getBlackMoves()
    _.minBy moves, (move) => move.manhattanDistance()

  longestAIMove: ->
    moves = @_getBlackMoves()
    _.maxBy moves, (move) => move.manhattanDistance()

  _getBlackMoves: ->
    gameState = @lessonManager.gameState()
    blackPieceSquares = gameState.occupiedSquaresOfColor Chess.Piece.Colors.Black

    moves = []

    for fromSquare in blackPieceSquares
      for toSquare in gameState.getLegalDestinationsFromSquare fromSquare
        moves.push new Chess.Move fromSquare, toSquare

    moves
