AB = Artificial.Base
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard.TwoDimensional extends Chess.Interface.Chessboard.TwoDimensional
  onCreated: ->
    super arguments...

    @pieceAnimation = new AB.Event @

    # Reactively prepare animation information when game state changes.
    @autorun =>
      return unless provider = @provider()
      gameState = provider.gameState()

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
      fromSquare = @_findPreviousSquareForPiece piece, previousGameState, nextGameState, usedPreviousSquares
      fromSquare ?= @_findPreviousSquareForPromotedPiece piece, toSquare, previousGameState, nextGameState, usedPreviousSquares
      continue unless fromSquare

      usedPreviousSquares[fromSquare.name] = true
      
      continue if toSquare is @_skipMoveAnimationTo

      pieceAnimations.push
        move: new Chess.Move fromSquare, toSquare
        promotion: previousGameState.getPieceAtSquare(fromSquare).type is Chess.Piece.Types.Pawn and piece.type in Chess.Piece.PromotionTypes

    pieceAnimations

  _findPreviousSquareForPiece: (piece, previousGameState, nextGameState, usedPreviousSquares) ->
    for fromSquare in previousGameState.occupiedSquares()
      continue if usedPreviousSquares[fromSquare.name]
      continue unless previousGameState.hasPieceAtSquare piece, fromSquare
      continue if nextGameState.hasPieceAtSquare piece, fromSquare

      return fromSquare

  _findPreviousSquareForPromotedPiece: (piece, toSquare, previousGameState, nextGameState, usedPreviousSquares) ->
    return unless piece.type in Chess.Piece.PromotionTypes
    return unless toSquare.rankIndex in [0, 7]

    pawn = new Chess.Piece piece.color, Chess.Piece.Types.Pawn

    for fromSquare in previousGameState.occupiedSquares()
      continue if usedPreviousSquares[fromSquare.name]
      continue unless previousGameState.hasPieceAtSquare pawn, fromSquare
      continue if nextGameState.hasPieceAtSquare pawn, fromSquare
      continue unless toSquare in previousGameState.getLegalDestinationsFromSquare fromSquare

      return fromSquare
