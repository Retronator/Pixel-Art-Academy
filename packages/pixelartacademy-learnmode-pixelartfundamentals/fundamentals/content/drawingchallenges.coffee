PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

PixelArtSoftware = PAA.Challenges.Drawing.PixelArtSoftware

class LM.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges extends LM.Content.FutureContent
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges'
  @displayName: -> "Drawing challenges"
  @contents: -> [
    @JaggiesCleanup
    @PerfectDiagonals
    @PerfectCurves
    @AntiAliasing
    @DitheredValues
    @DitheredColors
  ]
  @initialize()

  class @JaggiesCleanup extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.JaggiesCleanup'
    @displayName: -> "Jaggies cleanup"
    @initialize()
    
  class @PerfectDiagonals extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.PerfectDiagonals'
    @displayName: -> "Perfect diagonals"
    @initialize()
  
  class @PerfectCurves extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.PerfectCurves'
    @displayName: -> "Perfect curves"
    @initialize()
  
  class @AntiAliasing extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.AntiAliasing'
    @displayName: -> "Anti-aliasing"
    @initialize()
  
  class @DitheredValues extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.DitheredValues'
    @displayName: -> "Dithered values"
    @initialize()
  
  class @DitheredColors extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.DitheredColors'
    @displayName: -> "Dithered colors"
    @initialize()
