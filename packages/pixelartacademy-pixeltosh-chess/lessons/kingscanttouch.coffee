PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.KingsCantTouch extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.KingsCantTouch'
  @displayName: -> "Kings can't touch"

  @category: -> Chess.Lessons.Categories.King

  @steps: -> [
    @ApproachKing
    @End
  ]

  @startingPosition: ->
    e1: 'K'
    e8: 'k'

  @initialize()
  
  aiMove: ->
    gameState = @lessonManager.gameState()
    whiteKingSquare = gameState.occupiedSquaresOfColor(Chess.Piece.Colors.White)[0]
    blackKingSquare = gameState.occupiedSquaresOfColor(Chess.Piece.Colors.Black)[0]
    targetSquare = Chess.Square.e7
    
    movesAroundTarget = _.filter gameState.getLegalMoves(), (move) =>
      distanceToTargetFile = Math.abs(move.to.fileIndex - targetSquare.fileIndex)
      distanceToTargetRank = Math.abs(move.to.rankIndex - targetSquare.rankIndex)
      Math.max(distanceToTargetFile, distanceToTargetRank) is 1
      
    kingDistanceToWhiteFile = Math.abs(whiteKingSquare.fileIndex - blackKingSquare.fileIndex)
    kingDistanceToWhiteRank = Math.abs(whiteKingSquare.rankIndex - blackKingSquare.rankIndex)
    prioritizeRank = kingDistanceToWhiteRank >= kingDistanceToWhiteFile

    sortedMoves = _.sortBy movesAroundTarget, (move) =>
      distanceToWhiteFile = Math.abs(whiteKingSquare.fileIndex - move.to.fileIndex)
      distanceToWhiteRank = Math.abs(whiteKingSquare.rankIndex - move.to.rankIndex)
      
      if prioritizeRank
        -distanceToWhiteRank * 10 + distanceToWhiteFile
        
      else
        -distanceToWhiteFile * 10 + distanceToWhiteRank
    
    sortedMoves[0]
  
  Lesson = @

  class @ApproachKing extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.ApproachKing"

    @message: -> """
      The enemy king stands alone at the far end of the board. March your king up the file to confront him. The target sits on e7, right at his side.
    """

    @initialize()

    completed: -> @gameState().occupiedSquaresOfColor(Chess.Piece.Colors.White)[0].manhattanDistanceTo(Chess.Square.e7) is 1
    
    markup: -> [
      target:
        position: Chess.Square.e7
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Two squares apart, and no closer. Step onto e7 and your king would be in check, which is forbidden. The same holds for Black.
      
      This face-off has a name: the opposition. In many endgames the king who forces the other to give way is the one who wins.
    """

    @initialize()

    markup: -> [
      target:
        position: Chess.Square.e7
    ]
