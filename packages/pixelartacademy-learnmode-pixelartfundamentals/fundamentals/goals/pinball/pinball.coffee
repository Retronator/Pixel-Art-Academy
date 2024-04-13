AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.Pinball extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Pinball'

  @displayName: -> "Pinball"

  @chapter: -> LM.PixelArtFundamentals.Fundamentals

  @tasks: -> [
    @OpenPinballMachine
    @DrawBall
    @PlayBall
    @DrawPlayfield
    @PlayPlayfield
    @DrawGobbleHole
    @PlayGobbleHole
    @AddPins
    @DrawBallTrough
    @PlayBallTrough
    @DrawBumper
    @PlayBumper
    @DrawGate
    @PlayGate
    @RemoveGobbleHoles
    @DrawFlipper
    @PlayFlipper
    @DrawLowerThird
    @DrawUpperThird
    @ActiveBumpers
    @DrawSpinningTarget
    @PlaySpinningTarget
  ]

  @finalTasks: -> [
    @PlaySpinningTarget
  ]

  @initialize()
