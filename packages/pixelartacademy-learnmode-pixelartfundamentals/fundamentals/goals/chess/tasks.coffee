AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Goal = LM.PixelArtFundamentals.Fundamentals.Goals.Chess
Chess = PAA.Pixeltosh.Programs.Chess

class Goal.BuyPawn extends Goal.Task
  @id: -> "#{Goal.id()}.BuyPawn"
  @goal: -> Goal

  @directive: -> "Buy a pawn"

  @instructions: -> """
    In the Pixeltosh app, open the Chess Academy drive and run the Chess Academy program.
    Choose either 2D or 3D view and buy your first pawn.
  """

  @interests: -> ['chess', 'video game']

  @requiredInterests: -> ['size (pixel art)']

  @studyPlanBuilding: -> 'SimCitySubway'

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
  
  @studyPlanBuilding: -> 'SimCitySubway'
  
  @initialize()
  
  @completedConditions: -> Chess.eitherAssetIsDrawn Chess.Piece.Types.Pawn, Chess.Piece.Colors.White

class Goal.DrawBlackPawn extends Goal.Task
  @id: -> "#{Goal.id()}.DrawBlackPawn"
  @goal: -> Goal
  
  @directive: -> "Draw a black pawn"
  
  @instructions: -> """
     In the Drawing app, draw a black pawn by copying the white pawn with the option on the clipboard and recoloring it to a dark color.
  """
  
  @predecessors: -> [Goal.DrawWhitePawn]
  
  @studyPlanBuilding: -> 'SimCitySubway'
  
  @initialize()
  
  @completedConditions: -> Chess.eitherAssetIsDrawn Chess.Piece.Types.Pawn, Chess.Piece.Colors.Black

class Goal.PawnLessons extends Goal.Task
  @id: -> "#{Goal.id()}.PawnLessons"
  @goal: -> Goal
  
  @directive: -> "Complete the pawn lessons"
  
  @instructions: -> """
     Return to Chess Academy and complete the lessons about pawn rules, until you have enough chess points to buy a new piece type.
  """
  
  @predecessors: -> [Goal.DrawBlackPawn]
  
  @studyPlanBuilding: -> 'SimCitySubway'
  
  @initialize()
  
  @completedConditions: -> false

class Goal.PlayGame extends Goal.Task
  @id: -> "#{Goal.id()}.PlayGame"
  @goal: -> Goal
  
  @directive: -> "Play a full chess game"
  
  @instructions: -> """
    With all your chess pieces purchased, you can now play a full game of chess.
  """
  
  @predecessors: -> [Goal.PawnLessons]
  
  @studyPlanBuilding: -> 'SimCitySubway'
  
  @initialize()
  
  @completedConditions: -> false
