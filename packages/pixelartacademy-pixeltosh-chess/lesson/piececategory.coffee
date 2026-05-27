PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lesson.PieceCategory extends Chess.Lesson.Category
  @pieceType: -> throw new AE.NotImplementedException "You must specify which piece type unlocks this category."
  
  pieceType: -> @constructor.pieceType()
  
  available: ->
    return unless gameManager = @lessonManager.chess.gameManager()
    gameManager.ownedPiecesCount @pieceType()
