PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials extends LM.Content.FutureContent
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials'
  @displayName: -> "Drawing tutorials"
  @contents: -> [
    @Diagonals
    @Curves
    @AntiAliasing
    @Dithering
    @Rotation
    @Scale
  ]
  @initialize()
  
  class @Diagonals extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Diagonals'
    @displayName: -> "Pixel art diagonals"
    @initialize()
  
  class @Curves extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Curves'
    @displayName: -> "Pixel art curves"
    @initialize()
  
  class @AntiAliasing extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.AntiAliasing'
    @displayName: -> "Anti-aliasing"
    @initialize()
  
  class @Dithering extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Dithering'
    @displayName: -> "Dithering"
    @initialize()
  
  class @Rotation extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Rotation'
    @displayName: -> "Pixel art rotation"
    @initialize()
    
  class @Scale extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Scale'
    @displayName: -> "Pixel art scale"
    @initialize()
