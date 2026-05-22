AE = Artificial.Everywhere
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

ChessEngine = require 'js-chess-engine'

class Chess.GameManager
  constructor: (@chess) ->
    @currency = @chess.state.field 'currency', default: 0
    @ownedPieceTypeCounts = @chess.state.field 'ownedPieceTypeCounts', default: {}
    
    @game = new AE.ReactiveWrapper null

    @gameState = new AE.LiveComputedField =>
      # In the menu, we show a special board with
      return @generateMenuGameState() if @chess.interfaceManager()?.inMenu()
      
      # Otherwise, read the state from the engine game.
      return unless game = @game.withUpdates()
      boardConfig = game.exportJson()
      console.log "new state", boardConfig
      new Chess.GameState boardConfig

    # Give the player the first currency if they have no pieces.
    Tracker.autorun (computation) =>
      return unless LOI.adventure.gameState()
      computation.stop()
      
      @currency 1 unless @ownedPiecesCount() or @currency()
    
    # Throw an error if a piece a player owns doesn't have a drawn asset in the current project.
    @_missingAssetsAutorun = @chess.autorun (computation) =>
      return if @chess.os.interface.dialogs().length
      
      return unless LOI.adventure.gameState()
      return unless project = PAA.Practice.Project.documents.findOne Chess.chessSet2D()
      
      assetIsDrawn = (assetId) =>
        return unless asset = _.find project.assets, (asset) => asset.id is assetId
        return unless bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId asset?.bitmapId, false
        bitmap.historyPosition
        
      throwError = (color, pieceType) =>
        @chess.os.throwError
          reason: "file not found"
          details: "#{color} #{pieceType.toLowerCase()}"
          shutDownProgram: @chess
      
      for pieceType, count of @ownedPieceTypeCounts() when count
        unless assetIsDrawn Chess.Assets.TwoDimensional[pieceType].White.id()
          throwError 'white', pieceType
          return
        
        unless assetIsDrawn Chess.Assets.TwoDimensional[pieceType].Black.id()
          throwError 'black', pieceType
          return
  
  destroy: ->
    @_missingAssetsAutorun.stop()
  
  generateMenuGameState: ->
    data = Chess.GameState.getEmptyData()
    
    for fileIndex in [0...@ownedPiecesCount Chess.Piece.Types.Pawn]
      data.pieces[Chess.GameState.getSquareName fileIndex, 1] = Chess.Piece.getLetter Chess.Piece.Colors.White, Chess.Piece.Types.Pawn
    
    for pieceIndex in [0...@ownedPiecesCount Chess.Piece.Types.Knight]
      data.pieces[Chess.GameState.getSquareName 1 + pieceIndex * 5, 0] = Chess.Piece.getLetter Chess.Piece.Colors.White, Chess.Piece.Types.Knight
    
    for pieceIndex in [0...@ownedPiecesCount Chess.Piece.Types.Rook]
      data.pieces[Chess.GameState.getSquareName pieceIndex * 7, 0] = Chess.Piece.getLetter Chess.Piece.Colors.White, Chess.Piece.Types.Rook
    
    for pieceIndex in [0...@ownedPiecesCount Chess.Piece.Types.Bishop]
      data.pieces[Chess.GameState.getSquareName 2 + pieceIndex * 3, 0] = Chess.Piece.getLetter Chess.Piece.Colors.White, Chess.Piece.Types.Bishop
    
    if @ownedPiecesCount Chess.Piece.Types.Queen
      data.pieces[Chess.GameState.getSquareName 3, 0] = Chess.Piece.getLetter Chess.Piece.Colors.White, Chess.Piece.Types.Queen
    
    if @ownedPiecesCount Chess.Piece.Types.King
      data.pieces[Chess.GameState.getSquareName 4, 0] = Chess.Piece.getLetter Chess.Piece.Colors.White, Chess.Piece.Types.King
    
    new Chess.GameState data
    
  ownedPiecesCount: (pieceType) ->
    counts = @ownedPieceTypeCounts()

    if pieceType
      counts[pieceType] or 0
      
    else
      _.sum _.values counts
