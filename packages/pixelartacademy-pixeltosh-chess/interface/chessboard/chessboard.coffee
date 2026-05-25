LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Chessboard'
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @chess = @os.getProgram Chess

    @selectedSquare = new ReactiveField null

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

  legalMoveSquares: ->
    return [] unless @chess.gameManager()?.humanCanMove()
    return [] unless selectedSquare = @selectedSquare()

    @chess.gameManager().getLegalMovesFromSquare selectedSquare

  humanCanMovePieceOnSquare: (square) ->
    return unless gameManager = @chess.gameManager()
    return unless gameManager.humanCanMove()
    
    gameState = gameManager.gameState()
    piece = gameState.getPieceAtSquare square
    piece?.color is gameState.turn() and gameManager.getLegalMovesFromSquare(square).length
    
  performMoveTo: (square) ->
    @chess.gameManager().move new Chess.Move @selectedSquare(), square
    @selectedSquare null
    
    # Reset the grabbing cursor since the piece element will be removed
    # and the pointer leave event will not handle the cursor change.
    @chess.os.cursor().setClass null

  coordinatesVisibleClass: ->
    'visible' if @chess.interfaceManager()?.displayBoardCoordinates()

  flippedClass: ->
    'flipped' if @chess.interfaceManager()?.flippedBoard()

  onClickSquare: (square) ->
    if @_ignoreNextClick
      @_ignoreNextClick = false
      return

    return unless gameManager = @chess.gameManager()
    return unless gameManager.humanCanMove()

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
