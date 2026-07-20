AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess
PlayerPositions = Chess.Interface.Play.PlayerPositions

class Chess.Interface.Play.PlayerCard extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Play.PlayerCard'
  @register @id()

  @MaterialPieceTypes = [
    Chess.Piece.Types.Queen
    Chess.Piece.Types.Rook
    Chess.Piece.Types.Bishop
    Chess.Piece.Types.Knight
    Chess.Piece.Types.Pawn
  ]

  @_pieceContentBoundsCache = {}

  onCreated: ->
    super arguments...

    @play = @ancestorComponentOfType Chess.Interface.Play
    @chess = @play.chess

    @color = new ComputedField =>
      playerPosition = @data()
      flipped = @chess.interfaceManager()?.flippedBoard()

      # White is on the bottom if not flipped, black if interface is flipped.
      if (playerPosition is PlayerPositions.Bottom and not flipped) or (playerPosition is PlayerPositions.Top and flipped)
        Chess.Piece.Colors.White

      else
        Chess.Piece.Colors.Black

    @name = new ComputedField =>
      return unless gameOptions = @chess.gameManager()?.gameOptions()
      player = gameOptions[@color().toLowerCase()]

      switch player.type
        when Chess.GameManager.PlayerTypes.Human then "Player"
        when Chess.GameManager.PlayerTypes.Computer then "Pixeltosh"

    @kingPiece = new ComputedField => new Chess.Piece @color(), Chess.Piece.Types.King

    @capturedPieces = new ComputedField =>
      color = @color()
      opponentColor = @_opponentColor color
      return unless playerCapturedPieceCounts = @_capturedPieceCountsForColor opponentColor
      return unless opponentCapturedPieceCounts = @_capturedPieceCountsForColor color

      pieces = []

      for pieceType in @constructor.MaterialPieceTypes
        differentCapturedPieceCount = Math.max 0, playerCapturedPieceCounts[pieceType] - opponentCapturedPieceCounts[pieceType]

        for pieceIndex in [0...differentCapturedPieceCount]
          piece = new Chess.Piece opponentColor, pieceType
          pieces.push
            piece: piece
            style: @capturedPieceStyle piece

      pieces

    @materialDifference = new ComputedField =>
      color = @color()
      @_materialValueForColor(color) - @_materialValueForColor(@_opponentColor color)

  materialDifferenceText: ->
    materialDifference = @materialDifference()
    "+#{materialDifference}" if materialDifference > 0

  capturedPieceStyle: (piece) ->
    return unless contentBounds = @_contentBoundsForPiece piece

    width: "#{contentBounds.width}rem"
    left: "#{-contentBounds.x}rem"
    top: "#{20 - contentBounds.height - contentBounds.y}rem"

  _opponentColor: (color) ->
    if color is Chess.Piece.Colors.White then Chess.Piece.Colors.Black else Chess.Piece.Colors.White

  _capturedPieceCountsForColor: (color) ->
    return unless gameState = @chess.gameManager()?.gameState()
    
    capturedPieceCounts = {}

    for pieceType in @constructor.MaterialPieceTypes
      startingCount = Chess.Piece.InfoForType[pieceType].requiredCount
      remainingCount = gameState.getPiecesOfTypeAndColor(pieceType, color).length
      capturedPieceCounts[pieceType] = Math.max 0, startingCount - remainingCount

    capturedPieceCounts

  _materialValueForColor: (color) ->
    return 0 unless gameState = @chess.gameManager()?.gameState()

    materialValue = 0

    for piece in gameState.getPiecesOfColor color when piece.type isnt Chess.Piece.Types.King
      materialValue += Chess.Piece.InfoForType[piece.type].value

    materialValue

  _contentBoundsForPiece: (piece) ->
    return unless project = PAA.Practice.Project.documents.findOne Chess.projectId2D()
    
    assetId = Chess.Assets.TwoDimensional[piece.type][piece.color].id()
    return unless asset = _.find project.assets, (asset) => asset.id is assetId
    
    bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId asset.bitmapId, false
    cacheItem = @constructor._pieceContentBoundsCache[asset.bitmapId]

    # Update cache if necessary.
    unless cacheItem?.lastEditTime is bitmap.lastEditTime
      cacheItem =
        lastEditTime: bitmap.lastEditTime
        bounds: bitmap.getContentBounds()

      @constructor._pieceContentBoundsCache[asset.bitmapId] = cacheItem

    cacheItem.bounds
