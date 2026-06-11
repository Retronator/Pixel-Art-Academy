AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Goal = LM.PixelArtFundamentals.Fundamentals.Goals.Chess
Chess = PAA.Pixeltosh.Programs.Chess

class Goal.TwoDimensional extends Goal.Task
  @id: -> "#{Goal.id()}.TwoDimensional"
  @goal: -> Goal
  
  @directive: -> "Choose the 2D chessboard"
  
  @instructions: -> """
    In the Pixeltosh app, open the Chess Academy drive and run the Chess Academy program.
    Choose the 2D board style to begin.
  """
  
  @groupNumber: -> -1
  
  @requiredInterests: -> ['size (pixel art)']
  
  @studyPlanBuilding: -> 'CountyLineSign'
  
  @initialize()
  
  @completedConditions: -> Chess.state('boardDisplayType') is Chess.BoardDisplayTypes.TwoDimensional

class Goal.ThreeDimensional extends Goal.Task
  @id: -> "#{Goal.id()}.ThreeDimensional"
  @goal: -> Goal
  
  @directive: -> "Choose the 3D chessboard"
  
  @instructions: -> """
    In the Pixeltosh app, open the Chess Academy drive and run the Chess Academy program.
    Choose the 3D board style to begin.
  """
  
  @groupNumber: -> 1
  
  @requiredInterests: -> ['form']
  
  @studyPlanBuilding: -> 'TransportTycoonDepot'
  
  @initialize()
  
  @completedConditions: -> Chess.state('boardDisplayType') is Chess.BoardDisplayTypes.ThreeDimensional

class Goal.BuyPawn extends Goal.Task
  @id: -> "#{Goal.id()}.BuyPawn"
  @goal: -> Goal

  @directive: -> "Buy a pawn"

  @instructions: -> """
    In Chess Academy on the Pixeltosh, click the buy button to open the shop and buy a pawn.
  """

  @predecessors: -> [
    Goal.TwoDimensional
    Goal.ThreeDimensional
  ]

  @predecessorsCompleteType: -> @PredecessorsCompleteTypes.Any

  @studyPlanBuilding: -> 'TransportTycoonHouses1'

  @initialize()

  @completedConditions: -> Chess.ownedPiecesCount Chess.Piece.Types.Pawn

class Goal.DrawWhitePawn extends Goal.Task
  @id: -> "#{Goal.id()}.DrawWhitePawn"
  @goal: -> Goal
  
  @directive: -> "Draw a white pawn"
  
  @instructions: -> """
     In the Drawing app, find either the 2D or 3D chess project and draw a white pawn.
  """
  
  @predecessors: -> [Goal.BuyPawn]
  
  @studyPlanBuilding: -> 'TransportTycoonHouse4'
  
  @initialize()
  
  @completedConditions: -> Chess.assetIsDrawnInEitherDimension Chess.Piece.Types.Pawn, Chess.Piece.Colors.White

class Goal.DrawBlackPawn extends Goal.Task
  @id: -> "#{Goal.id()}.DrawBlackPawn"
  @goal: -> Goal
  
  @directive: -> "Draw a black pawn"
  
  @instructions: -> """
     In the Drawing app, draw a black pawn by using the clipboard option to copy the white pawn and recoloring it to a dark shade.
  """
  
  @predecessors: -> [Goal.DrawWhitePawn]
  
  @studyPlanBuilding: -> 'TransportTycoonHouses2'
  
  @initialize()
  
  @completedConditions: -> Chess.assetIsDrawnInEitherDimension Chess.Piece.Types.Pawn, Chess.Piece.Colors.Black

class Goal.PawnLessons extends Goal.Task
  @id: -> "#{Goal.id()}.PawnLessons"
  @goal: -> Goal
  
  @directive: -> "Complete the pawn lessons"
  
  @instructions: -> """
     Return to Chess Academy and complete the lessons about pawn rules, until you have enough currency to buy a new piece type.
  """
  
  @predecessors: -> [Goal.DrawBlackPawn]
  
  @studyPlanBuilding: -> 'TransportTycoonBusStation'
  
  @initialize()
  
  @completedConditions: -> Chess.currency() >= 3

class Goal.BuyKnight extends Goal.Task
  @id: -> "#{Goal.id()}.BuyKnight"
  @goal: -> Goal

  @directive: -> "Buy a knight"

  @instructions: -> """
    In Chess Academy on the Pixeltosh, buy a knight in the shop.
  """

  @predecessors: -> [Goal.PawnLessons]

  @groupNumber: -> -3

  @studyPlanBuilding: -> 'TransportTycoonPark2'

  @initialize()

  @completedConditions: -> Chess.ownedPiecesCount Chess.Piece.Types.Knight

class Goal.DrawKnight extends Goal.Task
  @id: -> "#{Goal.id()}.DrawKnight"
  @goal: -> Goal

  @directive: -> "Draw knight sprites"

  @instructions: -> """
    In the Drawing app, draw the white and black knights. You can copy the white pawn art as a base for the new piece.
  """

  @predecessors: -> [Goal.BuyKnight]

  @groupNumber: -> -3

  @studyPlanBuilding: -> 'TransportTycoonHouses3'

  @initialize()

  @completedConditions: -> Chess.assetIsDrawnInEitherDimension(Chess.Piece.Types.Knight, Chess.Piece.Colors.White) and Chess.assetIsDrawnInEitherDimension(Chess.Piece.Types.Knight, Chess.Piece.Colors.Black)

class Goal.BuySecondKnight extends Goal.Task
  @id: -> "#{Goal.id()}.BuySecondKnight"
  @goal: -> Goal

  @directive: -> "Buy a second knight"

  @instructions: -> """
    In Chess Academy on the Pixeltosh, buy your second knight.
  """

  @predecessors: -> [Goal.DrawKnight]

  @groupNumber: -> -3

  @studyPlanBuilding: -> 'TransportTycoonPark1'

  @initialize()

  @completedConditions: -> Chess.ownedPiecesCount(Chess.Piece.Types.Knight) is 2

class Goal.BuyBishop extends Goal.Task
  @id: -> "#{Goal.id()}.BuyBishop"
  @goal: -> Goal

  @directive: -> "Buy a bishop"

  @instructions: -> """
    In Chess Academy on the Pixeltosh, buy a bishop in the shop.
  """

  @predecessors: -> [Goal.PawnLessons]

  @groupNumber: -> -2

  @studyPlanBuilding: -> 'TransportTycoonChurch'

  @initialize()

  @completedConditions: -> Chess.ownedPiecesCount Chess.Piece.Types.Bishop

class Goal.DrawBishop extends Goal.Task
  @id: -> "#{Goal.id()}.DrawBishop"
  @goal: -> Goal

  @directive: -> "Draw bishop sprites"

  @instructions: -> """
    In the Drawing app, draw the white and black bishops. You can copy your previous chess piece art as a base for the new piece.
  """

  @predecessors: -> [Goal.BuyBishop]

  @groupNumber: -> -2

  @studyPlanBuilding: -> 'TransportTycoonFlats1'

  @initialize()

  @completedConditions: -> Chess.assetIsDrawnInEitherDimension(Chess.Piece.Types.Bishop, Chess.Piece.Colors.White) and Chess.assetIsDrawnInEitherDimension(Chess.Piece.Types.Bishop, Chess.Piece.Colors.Black)

class Goal.BuySecondBishop extends Goal.Task
  @id: -> "#{Goal.id()}.BuySecondBishop"
  @goal: -> Goal

  @directive: -> "Buy a second bishop"

  @instructions: -> """
    In Chess Academy on the Pixeltosh, buy another bishop.
  """

  @predecessors: -> [Goal.DrawBishop]

  @groupNumber: -> -2

  @studyPlanBuilding: -> 'SimCityChurch'

  @initialize()

  @completedConditions: -> Chess.ownedPiecesCount(Chess.Piece.Types.Bishop) is 2

class Goal.BuyRook extends Goal.Task
  @id: -> "#{Goal.id()}.BuyRook"
  @goal: -> Goal

  @directive: -> "Buy a rook"

  @instructions: -> """
    In Chess Academy on the Pixeltosh, buy a rook in the shop.
  """

  @predecessors: -> [Goal.PawnLessons]

  @groupNumber: -> -1

  @studyPlanBuilding: -> 'SimCityOffice3'

  @initialize()

  @completedConditions: -> Chess.ownedPiecesCount Chess.Piece.Types.Rook

class Goal.DrawRook extends Goal.Task
  @id: -> "#{Goal.id()}.DrawRook"
  @goal: -> Goal

  @directive: -> "Draw rook sprites"

  @instructions: -> """
    In the Drawing app, draw the white and black rooks. You can copy your previous chess piece art as a base for the new piece.
  """

  @predecessors: -> [Goal.BuyRook]

  @groupNumber: -> -1

  @studyPlanBuilding: -> 'TransportTycoonHouses4'

  @initialize()

  @completedConditions: -> Chess.assetIsDrawnInEitherDimension(Chess.Piece.Types.Rook, Chess.Piece.Colors.White) and Chess.assetIsDrawnInEitherDimension(Chess.Piece.Types.Rook, Chess.Piece.Colors.Black)

class Goal.BuySecondRook extends Goal.Task
  @id: -> "#{Goal.id()}.BuySecondRook"
  @goal: -> Goal

  @directive: -> "Buy a second rook"

  @instructions: -> """
    In Chess Academy on the Pixeltosh, buy another rook.
  """

  @predecessors: -> [Goal.DrawRook]

  @groupNumber: -> -1

  @studyPlanBuilding: -> 'TransportTycoonOffice1'

  @initialize()

  @completedConditions: -> Chess.ownedPiecesCount(Chess.Piece.Types.Rook) is 2

class Goal.BuyQueen extends Goal.Task
  @id: -> "#{Goal.id()}.BuyQueen"
  @goal: -> Goal

  @directive: -> "Buy a queen"

  @instructions: -> """
    In Chess Academy on the Pixeltosh, buy a queen in the shop.
  """

  @predecessors: -> [Goal.PawnLessons]

  @groupNumber: -> 0

  @studyPlanBuilding: -> 'TransportTycoonOffice4'

  @initialize()

  @completedConditions: -> Chess.ownedPiecesCount Chess.Piece.Types.Queen

class Goal.DrawQueen extends Goal.Task
  @id: -> "#{Goal.id()}.DrawQueen"
  @goal: -> Goal

  @directive: -> "Draw queen sprites"

  @instructions: -> """
    In the Drawing app, draw the white and black queens. You can copy your previous chess piece art as a base for the new piece.
  """

  @predecessors: -> [Goal.BuyQueen]

  @groupNumber: -> 0

  @studyPlanBuilding: -> 'TransportTycoonShops2'

  @initialize()

  @completedConditions: -> Chess.assetIsDrawnInEitherDimension(Chess.Piece.Types.Queen, Chess.Piece.Colors.White) and Chess.assetIsDrawnInEitherDimension(Chess.Piece.Types.Queen, Chess.Piece.Colors.Black)

class Goal.BuyKing extends Goal.Task
  @id: -> "#{Goal.id()}.BuyKing"
  @goal: -> Goal

  @directive: -> "Buy a king"

  @instructions: -> """
    In Chess Academy on the Pixeltosh, buy a king in the shop.
  """

  @predecessors: -> [Goal.PawnLessons]

  @groupNumber: -> 1

  @studyPlanBuilding: -> 'TransportTycoonOffice3'

  @initialize()

  @completedConditions: -> Chess.ownedPiecesCount Chess.Piece.Types.King

class Goal.DrawKing extends Goal.Task
  @id: -> "#{Goal.id()}.DrawKing"
  @goal: -> Goal

  @directive: -> "Draw king sprites"

  @instructions: -> """
    In the Drawing app, draw the white and black kings. You can copy your previous chess piece art as a base for the new piece.
  """

  @predecessors: -> [Goal.BuyKing]

  @groupNumber: -> 1

  @studyPlanBuilding: -> 'TransportTycoonTheater'

  @initialize()

  @completedConditions: -> Chess.assetIsDrawnInEitherDimension(Chess.Piece.Types.King, Chess.Piece.Colors.White) and Chess.assetIsDrawnInEitherDimension(Chess.Piece.Types.King, Chess.Piece.Colors.Black)

class Goal.KingLessons extends Goal.Task
  @id: -> "#{Goal.id()}.KingLessons"
  @goal: -> Goal
  
  @directive: -> "Complete the king lessons"
  
  @instructions: -> """
     In Chess Academy on the Pixeltosh, learn how winning and losing works in the king lessons.
  """
  
  @predecessors: -> [Goal.DrawKing]
  
  @groupNumber: -> 1
  
  @studyPlanBuilding: -> 'TransportTycoonFlats2'
  
  @initialize()
  
  @completedConditions: -> Chess.Lessons.Categories.King.completed()
  
class Goal.BuyPawns extends Goal.Task
  @id: -> "#{Goal.id()}.BuyPawns"
  @goal: -> Goal
  
  @directive: -> "Buy all 8 pawns"
  
  @instructions: -> """
    In Chess Academy on the Pixeltosh, complete your set of pawns.
  """
  
  @predecessors: -> [Goal.PawnLessons]
  
  @groupNumber: -> 2
  
  @studyPlanBuilding: -> 'TransportTycoonWarehouse'
  
  @initialize()
  
  @completedConditions: -> Chess.ownedPiecesCount(Chess.Piece.Types.Bishop) is 2
  
class Goal.PlayGame extends Goal.Task
  @id: -> "#{Goal.id()}.PlayGame"
  @goal: -> Goal
  
  @directive: -> "Play a full chess game"
  
  @instructions: -> """
    With all your chess pieces purchased, you can now play a full game of chess.

    In Chess Academy on the Pixeltosh, switch from the Lessons tab to the Play tab in the sidebar and start playing a game with any settings.
  """
  
  @interests: -> ['chess', 'video game']
  
  @predecessors: -> [
    Goal.BuySecondKnight
    Goal.BuySecondBishop
    Goal.BuySecondRook
    Goal.DrawQueen
    Goal.KingLessons
    Goal.BuyPawns
  ]
  
  @studyPlanBuilding: -> 'TransportTycoon'
  
  @initialize()
  
  @completedConditions: -> Chess.state 'playStarted'
