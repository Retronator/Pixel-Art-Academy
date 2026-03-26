AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves'

  @fullName: -> "Pixel art curves"

  @initialize()
  
  @assets: -> [
    @SmoothCurves
    @AbruptSegmentLengthChanges
    @StraightParts
    @InflectionPoints
    @LineArtCleanup
    @Circles
    @LongCurves
  ]
  
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.Curves
