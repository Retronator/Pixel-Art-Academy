AE = Artificial.Everywhere
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lesson.PositionStep extends Chess.Lesson.Step
  @requiredPosition: -> throw new AE.NotImplementedException "Position step must define the position that needs to be reached for completion."

  completed: ->
    return unless gameState = @gameState()
    
    for squareName, pieceLetter of @constructor.requiredPosition()
      square = Chess.Square[squareName]
      
      if pieceLetter
        return unless gameState.hasPieceAtSquare Chess.Piece.fromLetter(pieceLetter), square
        
      else
        return if gameState.isSquareOccupied square
      
    true
