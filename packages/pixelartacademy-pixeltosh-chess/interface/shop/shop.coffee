AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Shop extends FM.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Shop'
  @register @id()

  @createInterfaceData: ->
    contentComponentId: @id()
    programId: PAA.Pixeltosh.Programs.Chess.id()
    left: 0
    top: 0
    right: 0
    bottom: 0

  onCreated: ->
    super arguments...

    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @chess = @os.getProgram Chess

  pieces: ->
    for pieceType in _.values Chess.Piece.Types
      pieceData = Chess.Piece.InfoForType[pieceType]

      _.extend {type: pieceType}, pieceData

  ownedCount: ->
    piece = @currentData()
    Chess.ownedPiecesCount piece.type
    
  needsPiece: ->
    piece = @currentData()
    Chess.ownedPiecesCount(piece.type) < piece.requiredCount
  
  buyButtonDisabledAttribute: ->
    piece = @currentData()
    
    'disabled' if @chess.gameManager()?.currency() < piece.price
    
  events: ->
    super(arguments...).concat
      'click .buy-button': @onClickBuyButton
      'click .close-button': @onClickCloseButton

  onClickBuyButton: (event) ->
    piece = @currentData()
    gameManager = @chess.gameManager()
    
    gameManager.currency gameManager.currency() - piece.price

    ownedPieceTypeCounts = gameManager.ownedPieceTypeCounts()
    ownedPieceTypeCounts[piece.type] = (ownedPieceTypeCounts[piece.type] or 0) + 1
    gameManager.ownedPieceTypeCounts ownedPieceTypeCounts

  onClickCloseButton: (event) ->
    @chess.interfaceManager().closeShop()
