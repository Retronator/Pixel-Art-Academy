AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves extends PAA.Practice.Tutorials.Drawing.Tutorial
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves'

  @fullName: -> "Pixel art curves"

  @initialize()
  
  @assets: -> [
    @SmoothCurves
    @AbruptSegmentLengthChanges
    @LineArtCleanup
    @Circles
    @LongCurves
  ]
  
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArtCurves
