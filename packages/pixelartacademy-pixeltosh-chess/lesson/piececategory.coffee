PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lesson.PieceCategory extends Chess.Lesson.Category
  @pieceType: -> throw new AE.NotImplementedException "You must specify which piece type unlocks this category."
  
  pieceType: -> @constructor.pieceType()
  
  available: -> Chess.ownedPiecesCount @pieceType()
