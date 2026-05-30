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
        move = new Chess.Move fromSquare, toSquare
        
        # For promotions, set it to the best piece the player owns.
        piece = gameState.getPieceAtSquare move.from
        
        if piece.type is Chess.Piece.Types.Pawn and move.to.rankIndex in [0, 7]
          move.promotionPieceType = @lessonManager.chess.gameManager().bestOwnedPromotionPieceType()

        moves.push move

    moves
