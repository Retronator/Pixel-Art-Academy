AM = Artificial.Mirage
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard.TwoDimensional.Markup extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Chessboard.TwoDimensional.Markup'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @chessboard = @ancestorComponentOfType Chess.Interface.Chessboard.TwoDimensional
    
  markup: -> @chessboard.provider()?.markup?()
  
  squarePosition: (square) ->
    left = square.fileIndex * 21
    top = square.rankIndex * 21
    
    if @chessboard.chess.interfaceManager()?.flippedBoard()
      left = 147 - left
    
    else
      top = 147 - top
      
    {left, top}
  
  positionStyle: (square) ->
    {left, top} = @squarePosition square
    
    left: "#{left}rem"
    top: "#{top}rem"
  
  arrowStyle: ->
    arrow = @currentData()
    
    fromPosition = @squarePosition arrow.from
    toPosition = @squarePosition arrow.to
    
    left = toPosition.left + 10
    top = toPosition.top + 10
    scaleX = 1
    scaleY = 1
    rotate = 0
    
    leftDifference = toPosition.left - fromPosition.left
    leftDistance = Math.abs leftDifference
    
    topDifference = toPosition.top - fromPosition.top
    topDistance = Math.abs topDifference
    
    if leftDistance and topDistance and leftDistance > topDistance or not leftDistance
      # The arrow makes a longer horizontal move than vertical, so the arrow part will be vertical.
      width = leftDistance
      height = topDistance
      
      scaleX = -1 if leftDifference > 0
      scaleY = -1 if topDifference > 0
      
    else
      # The arrow will be horizontal, so we need to rotate 90 degrees.
      width = topDistance
      height = leftDistance
      rotate = 90
      
      scaleX = -1 if leftDifference < 0
      scaleY = -1 if topDifference > 0
    
    left: "#{left}rem"
    top: "#{top}rem"
    width: "#{width}rem"
    height: "#{height}rem"
    transform: "scale(#{scaleX}, #{scaleY}) rotate(#{rotate}deg)"
  
  straightArrowPart: ->
    not @diagonalArrowPart()
    
  orthogonalArrowPart: ->
    arrow = @currentData()
    (arrow.from.fileIndex isnt arrow.to.fileIndex or arrow.from.rankIndex isnt arrow.to.rankIndex) and not @diagonalArrowPart()
    
  diagonalArrowPart: ->
    arrow = @currentData()
    Math.abs(arrow.from.fileIndex - arrow.to.fileIndex) is Math.abs(arrow.from.rankIndex - arrow.to.rankIndex)
  
  legalMovesSquares: ->
    return unless selectedSquare = @chessboard.selectedSquare()
    
    @chessboard.provider()?.getLegalDestinationsFromSquare selectedSquare
