LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard.TwoDimensional extends Chess.Interface.Chessboard.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Chessboard.TwoDimensional'
  
  @Providers:
    GameManager: 'gameManager'
    LessonManager: 'lessonManager'
    
  onCreated: ->
    super arguments...
    
    @selectedSquare = new ReactiveField null
    @promotionInfo = new ReactiveField null

    # Create board squares.
    @squares = []

    for fileIndex in [0...8]
      file = []
      @squares.push file

      for rankIndex in [0...8]
        file[rankIndex] = new @constructor.Square @, Chess.Square[fileIndex][rankIndex]

  onRendered: ->
    super arguments...

    for rank in Chess.Square.RankNumbers
      @$('.ranks .border').append("<div class='coordinate'>#{rank}</div>")

    for file in Chess.Square.FileLetters
      @$('.files .border').append("<div class='coordinate'>#{file}</div>")

  provider: ->
    providerName = @data()
    @chess[providerName]()
      
  legalMoveSquares: ->
    return [] unless @provider()?.humanCanMove()
    return [] unless selectedSquare = @selectedSquare()

    @provider().getLegalDestinationsFromSquare selectedSquare

  humanCanMovePieceOnSquare: (square) ->
    return unless provider = @provider()
    return unless provider.humanCanMove()
    
    gameState = provider.gameState()
    piece = gameState.getPieceAtSquare square
    piece?.color is gameState.turn() and provider.getLegalDestinationsFromSquare(square).length
    
  performMoveTo: (square) ->
    selectedSquare = @selectedSquare()
    provider = @provider()
    gameState = provider.gameState()
    piece = gameState.getPieceAtSquare selectedSquare
    move = new Chess.Move selectedSquare, square
    
    if piece.type is Chess.Piece.Types.Pawn and move.to.rankIndex in [0, 7] and not @chess.interfaceManager().autoPromotion()
      @promotionInfo
        move: move
        color: piece.color
        
      provider.startPromotion move

    else
      @performMove move

  performMove: (move) ->
    @provider().move move
    @selectedSquare null
    @promotionInfo null
    
    # Reset the grabbing cursor since the piece element will be removed
    # and the pointer leave event will not handle the cursor change.
    @chess.os.cursor().setClass null
  
  choosePromotion: (pieceType) ->
    promotionInfo = @promotionInfo()
    promotionInfo.move.promotionPieceType = pieceType
    
    @performMove promotionInfo.move
    
  cancelPromotion: ->
    @promotionInfo null
    @selectedSquare null
    @provider().cancelPromotion()
    
  selectSquare: (square) ->
    @selectedSquare square

  coordinatesVisibleClass: ->
    return unless interfaceManager = @chess.interfaceManager()
    
    'visible' if interfaceManager.displayBoardCoordinates()

  flippedClass: ->
    'flipped' if @chess.interfaceManager()?.flippedBoard()

  onClickSquare: (square) ->
    if @_ignoreNextClick
      @_ignoreNextClick = false
      return

    return unless provider = @provider()
    return unless provider.humanCanMove()

    selectedSquare = @selectedSquare()

    if selectedSquare
      # Clicking the selected square cancels the current move.
      if square is selectedSquare
        @selectedSquare null
        return
        
      # If the player clicked one of the legal destination squares, move the selected piece.
      if square in @legalMoveSquares()
        @performMoveTo square
        return

    # Do piece selection or deselection.
    if @humanCanMovePieceOnSquare square
      @selectedSquare square

    else
      @selectedSquare null
