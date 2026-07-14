AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Shop extends PAA.Pixeltosh.Program.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Shop'
  @register @id()

  @createInterfaceData: ->
    contentComponentId: @id()
    programId: PAA.Pixeltosh.Programs.Chess.id()
    left: 0
    top: 0
    right: 0
    bottom: 0
    
  @StorePieces = [
    Chess.Piece.Types.Pawn
    Chess.Piece.Types.Bishop
    Chess.Piece.Types.Knight
    Chess.Piece.Types.Rook
    Chess.Piece.Types.Queen
    Chess.Piece.Types.King
  ]

  onCreated: ->
    super arguments...

    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @chess = @os.getProgram Chess

  pieces: ->
    for pieceType in @constructor.StorePieces
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
    
    'disabled' if Chess.currency() < piece.value
    
  events: ->
    super(arguments...).concat
      'click .buy-button': @onClickBuyButton
      'click .close-button': @onClickCloseButton

  onClickBuyButton: (event) ->
    piece = @currentData()

    # Prevent purchasing more than the required amount with fast clicking.
    ownedPieceTypeCounts = Chess.ownedPieceTypeCounts()
    return if ownedPieceTypeCounts[piece.type] >= piece.requiredCount
    
    Chess.currency Chess.currency() - piece.value
    ownedPieceTypeCounts[piece.type] = (ownedPieceTypeCounts[piece.type] or 0) + 1
    Chess.ownedPieceTypeCounts ownedPieceTypeCounts

  onClickCloseButton: (event) ->
    @chess.interfaceManager().closeShop()
