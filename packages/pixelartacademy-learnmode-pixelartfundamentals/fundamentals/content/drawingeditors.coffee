PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.DrawingEditors extends LM.Content.FutureContent
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingEditors'
  @displayName: -> "Drawing editors"
  @contents: -> [
    @Easel
    @PixelPaint
  ]
  @initialize()
  
  class @Easel extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingEditors.Easel'
    @displayName: -> "Easel"
    @initialize()

  class @PixelPaint extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingEditors.PixelPaint'
    @displayName: -> "PixelPaint"
    @initialize()
