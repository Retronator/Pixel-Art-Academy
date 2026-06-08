AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.Chess extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Chess'

  @displayName: -> "Chess"

  @chapter: -> LM.PixelArtFundamentals.Fundamentals

  @tasks: -> [
    @BuyPawn
    @DrawWhitePawn
    @DrawBlackPawn
    @PawnLessons
    @PlayGame
  ]

  @finalTasks: -> [
    @PlayGame
  ]

  @initialize()
  
  reset: ->
    super arguments...
    
    PAA.Pixeltosh.Programs.Chess.state 'ownedPieceTypeCounts', null
    PAA.Pixeltosh.Programs.Chess.state 'currency', null
    PAA.Pixeltosh.Programs.Chess.state 'boardDisplayType', null
    PAA.Pixeltosh.Programs.Chess.state 'Lessons', null
    PAA.Pixeltosh.Programs.Chess.Project.TwoDimensional.end()

  Goal = @
  
  class @Task extends PAA.Learning.Task.Automatic
