AM = Artificial.Mirage
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard.Square extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Chessboard.Square'
  @register @id()
  
  @Size = 21

  constructor: (@chessboard, @square) ->
    super arguments...

    @fileIndex = @square.fileIndex
    @rankIndex = @square.rankIndex
  
  legalMove: -> @square in @chessboard.legalMoveSquares()

  typeClass: ->
    if (@fileIndex + @rankIndex) % 2 then 'light' else 'dark'

  selectedClass: ->
    'selected' if @chessboard.selectedSquare() is @square

  legalMoveClass: ->
    'legal-move' if @legalMove()

  movablePieceClass: ->
    'movable-piece' if @chessboard.humanCanMovePieceOnSquare @square

  cursorAttribute: ->
    'data-cursor': 'grab' if @legalMove() or @chessboard.humanCanMovePieceOnSquare @square

  pieceRenderData: -> @chessboard.provider()?.gameState()?.getPieceAtSquare @square

  events: ->
    super(arguments...).concat
      'pointerdown': @onPointerDown
      'click': @onClick

  onPointerDown: (event) ->
    @chessboard.onPointerDownSquare @square, event

  onClick: (event) ->
    @chessboard.onClickSquare @square
