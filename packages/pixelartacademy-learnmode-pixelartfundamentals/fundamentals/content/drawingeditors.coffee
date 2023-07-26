PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.DrawingEditors extends LM.Content.FutureContent
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingEditors'
  @displayName: -> "Drawing editors"
  @contents: -> [
    @PixelPaint
  ]
  @initialize()

  class @PixelPaint extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.PixelPaint'
    @displayName: -> "PixelPaint"
    @initialize()
