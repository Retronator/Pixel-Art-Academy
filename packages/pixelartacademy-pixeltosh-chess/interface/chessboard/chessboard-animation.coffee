AB = Artificial.Base
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard extends Chess.Interface.Chessboard
  onCreated: ->
    super arguments...

    @pieceAnimation = new AB.Event @

    # Reactively prepare animation information when game state changes.
    @autorun =>
      return unless gameManager = @chess.gameManager()
      game = gameManager.game()

      # Reset animations when the game changes.
      unless game is @_previousGame
        @_previousGame = game
        @_previousGameState = null

      gameState = gameManager.gameState()

      # Reset animations when we don't have a game state anymore.
      unless gameState
        @_previousGameState = null
        return

      unless @_previousGameState
        @_previousGameState = gameState
        return

      previousGameState = @_previousGameState
      @_previousGameState = gameState

      @_animateGameStateChange previousGameState, gameState

  _animateGameStateChange: (previousGameState, nextGameState) ->
    return if previousGameState.hasSamePiecePlacementAs nextGameState

    pieceAnimations = @_createPieceAnimations previousGameState, nextGameState
    @_skipMoveAnimationTo = null

    return unless pieceAnimations.length

    Tracker.afterFlush =>
      @pieceAnimation pieceAnimation for pieceAnimation in pieceAnimations

  _createPieceAnimations: (previousGameState, nextGameState) ->
    usedPreviousSquares = {}
    pieceAnimations = []

    for toSquare in nextGameState.occupiedSquares()
      piece = nextGameState.getPieceAtSquare toSquare
      continue if previousGameState.hasPieceAtSquare piece, toSquare
      continue unless fromSquare = @_findPreviousSquareForPiece piece, previousGameState, nextGameState, usedPreviousSquares

      usedPreviousSquares[fromSquare.name] = true
      
      continue if toSquare is @_skipMoveAnimationTo

      pieceAnimations.push
        move: new Chess.Move fromSquare, toSquare

    pieceAnimations

  _findPreviousSquareForPiece: (piece, previousGameState, nextGameState, usedPreviousSquares) ->
    for fromSquare in previousGameState.occupiedSquares()
      continue if usedPreviousSquares[fromSquare.name]
      continue unless previousGameState.hasPieceAtSquare piece, fromSquare
      continue if nextGameState.hasPieceAtSquare piece, fromSquare

      return fromSquare
