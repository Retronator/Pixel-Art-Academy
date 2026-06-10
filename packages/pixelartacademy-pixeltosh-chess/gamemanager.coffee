AE = Artificial.Everywhere
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

ChessEngine = require 'js-chess-engine'

class Chess.GameManager
  @PlayerTypes =
    Human: 'Human'
    Computer: 'Computer'
  
  constructor: (@chess) ->
    @game = new AE.ReactiveWrapper null
    @gameOptions = new ReactiveField null
    @plyHistory = new ReactiveField []
    @previewedHistoryPlyNumber = new ReactiveField null
    @promotionGameState = new ReactiveField null

    @gameState = new AE.LiveComputedField =>
      # In the menu, we show a special board with the purchased pieces.
      return @_generateMenuGameState() if @chess.interfaceManager()?.inMenu()
      
      # Show any historic state.
      previewedHistoryPlyNumber = @previewedHistoryPlyNumber()
      return @plyHistory()[previewedHistoryPlyNumber].gameState if previewedHistoryPlyNumber?

      # During promotion, we show the temporary state with the pawn on the last rank.
      return promotionGameState if promotionGameState = @promotionGameState()

      # Otherwise, read the state from the engine game.
      return unless game = @game.withUpdates()
      boardConfig = game.exportJson()
      new Chess.GameState boardConfig

    # Give the player the first currency if they have no pieces.
    Tracker.autorun (computation) =>
      return unless LOI.adventure.gameState()
      computation.stop()
      
      Chess.currency 1 unless Chess.ownedPiecesCount() or Chess.currency()
    
    # Throw an error if a piece a player owns doesn't have a drawn asset in the current project.
    @_missingAssetsAutorun = @chess.autorun (computation) =>
      return if @chess.os.interface.getView PAA.Pixeltosh.OS.Interface.ErrorDialog
      
      return unless LOI.adventure.gameState()
      
      ownedPieceTypes = (pieceType for pieceType, count of Chess.ownedPieceTypeCounts() when count)
      @assertDrawnPieces ownedPieceTypes
  
    @_playAutorun = @chess.autorun (computation) =>
      return unless state = @gameState()
      return if state.finished()
      
      Tracker.nonreactive =>
        return unless game = @game()
        return unless @displayingLivePosition()

        # Determine whether it's computer's turn.
        options = @gameOptions()
        currentPlayerType = if state.turn() is Chess.Piece.Colors.White then options.whitePlayerType else options.blackPlayerType
        return unless currentPlayerType is @constructor.PlayerTypes.Computer
        
        # Make a move, but simulate as if it took a second to calculate.
        osCursor = @chess.os.cursor()
        osCursor.wait @
        startTime = Date.now()
        move = Chess.Move.fromEngine game.aiMove options.difficulty
        elapsedTime = (Date.now() - startTime) / 1000
        
        await _.waitForSeconds Math.max 0, 1 - elapsedTime
        
        osCursor.endWait @
        @game.updated()
        @_recordMove move

  destroy: ->
    @_missingAssetsAutorun.stop()
    @_playAutorun.stop()
    
  _generateMenuGameState: ->
    data = Chess.GameState.getEmptyData()
    
    for fileIndex in [0...Chess.ownedPiecesCount Chess.Piece.Types.Pawn]
      data.pieces[Chess.Square[fileIndex][1].engineName] = Chess.Piece.getLetter Chess.Piece.Colors.White, Chess.Piece.Types.Pawn
    
    for pieceIndex in [0...Chess.ownedPiecesCount Chess.Piece.Types.Knight]
      data.pieces[Chess.Square[1 + pieceIndex * 5][0].engineName] = Chess.Piece.getLetter Chess.Piece.Colors.White, Chess.Piece.Types.Knight
    
    for pieceIndex in [0...Chess.ownedPiecesCount Chess.Piece.Types.Rook]
      data.pieces[Chess.Square[pieceIndex * 7][0].engineName] = Chess.Piece.getLetter Chess.Piece.Colors.White, Chess.Piece.Types.Rook
    
    for pieceIndex in [0...Chess.ownedPiecesCount Chess.Piece.Types.Bishop]
      data.pieces[Chess.Square[2 + pieceIndex * 3][0].engineName] = Chess.Piece.getLetter Chess.Piece.Colors.White, Chess.Piece.Types.Bishop
    
    if Chess.ownedPiecesCount Chess.Piece.Types.Queen
      data.pieces[Chess.Square[3][0].engineName] = Chess.Piece.getLetter Chess.Piece.Colors.White, Chess.Piece.Types.Queen
    
    if Chess.ownedPiecesCount Chess.Piece.Types.King
      data.pieces[Chess.Square[4][0].engineName] = Chess.Piece.getLetter Chess.Piece.Colors.White, Chess.Piece.Types.King
    
    new Chess.GameState data
    
  assertDrawnPieces: (pieceTypes) ->
    throwError = (color, pieceType) =>
      @chess.os.throwError
        reason: "file not found"
        details: "#{color} #{pieceType.toLowerCase()}"
        shutDownProgram: @chess

      # Reset any cursor changes since pointer leave will not fire once the error overlay is displayed.
      @chess.os.cursor().setClass null
    
    for pieceType in pieceTypes
      unless Chess.activeAssetIsDrawn pieceType, Chess.Piece.Colors.White
        throwError 'white', pieceType
        return
      
      unless Chess.activeAssetIsDrawn pieceType, Chess.Piece.Colors.Black
        throwError 'black', pieceType
        return
    
  startGame: (options) ->
    @gameOptions options
    @plyHistory []
    @previewedHistoryPlyNumber null
    @promotionGameState null

    # Determine the starting board orientation.
    @chess.interfaceManager().flippedBoard options.whitePlayerType is @constructor.PlayerTypes.Computer and options.blackPlayerType is @constructor.PlayerTypes.Human

    # Create a new game with white able to make an ambiguous knight move.
    @game new ChessEngine.Game

    @plyHistory [
      number: 0
      gameState: new Chess.GameState EJSON.clone @game().exportJson()
    ]

  endGame: ->
    @game null
    @plyHistory []
    @previewedHistoryPlyNumber null
    @promotionGameState null

  getLegalDestinationsFromSquare: (square) ->
    return [] unless game = @game()

    moves = game.moves square.engineName
    return [] unless moves[square.engineName]

    Chess.Square[squareName] for squareName in moves[square.engineName]

  move: (move) ->
    unless game = @game()
      console.warn "Tried to move when there was no game is active."
      return

    unless @displayingLivePosition()
      console.warn "Tried to move when we weren't displaying the live position."
      return

    unless @humanCanMove()
      console.warn "Tried to move when it wasn't the human's turn."
      return

    unless move.to in @getLegalDestinationsFromSquare move.from
      console.warn "Tried to move to an illegal square."
      return

    game.move move.from.engineName, move.to.engineName

    if @promotionGameState()
      if move.promotionPieceType and move.promotionPieceType isnt Chess.Piece.Types.Queen
        # JS Chess Engine automatically promotes pawns to queens, so we have to override the piece.
        piece = @promotionGameState().getPieceAtSquare move.to
        promotionPieceLetter = Chess.Piece.getLetter piece.color, move.promotionPieceType
        game.setPiece move.to.engineName, promotionPieceLetter

      @promotionGameState null

    @game.updated()

    @_recordMove move

  _recordMove: (move) ->
    plyHistory = @plyHistory()

    plyHistory.push
      number: plyHistory.length
      move: move
      gameState: new Chess.GameState EJSON.clone @game().exportJson()

    @plyHistory plyHistory

  startPromotion: (move) ->
    @promotionGameState @gameState().startPromotion move

  cancelPromotion: ->
    @promotionGameState null

  displayPosition: (plyNumber) ->
    if plyNumber is @livePlyNumber()
      @previewedHistoryPlyNumber null

    else
      @previewedHistoryPlyNumber plyNumber

  currentPlayerType: ->
    return unless state = @gameState()
    return unless options = @gameOptions()

    if state.turn() is Chess.Piece.Colors.White then options.whitePlayerType else options.blackPlayerType

  humanCanMove: ->
    return unless @displayingLivePosition()

    @currentPlayerType() is @constructor.PlayerTypes.Human

  currentDisplayedPlyNumber: -> @previewedHistoryPlyNumber() ? @livePlyNumber()

  livePlyNumber: -> @plyHistory().length - 1

  liveGameState: -> _.last(@plyHistory())?.gameState

  displayingLivePosition: -> not @previewedHistoryPlyNumber()?

  ownedPiecesCount: (pieceType) ->
    counts = Chess.ownedPieceTypeCounts()

    if pieceType
      counts[pieceType] or 0
      
    else
      _.sum _.values counts

  bestOwnedPromotionPieceType: ->
    @_promotionTypesDescending ?= _.reverse _.clone Chess.Piece.PromotionTypes
    
    for pieceType in @_promotionTypesDescending
      return pieceType if Chess.ownedPiecesCount pieceType
