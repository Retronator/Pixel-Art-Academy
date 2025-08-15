AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals'

  @fullName: -> "Pixel art diagonals"

  @initialize()
  
  @assets: -> [
    @EvenDiagonals
    @ConstrainingAngles
    @UnevenDiagonals
    @SegmentLengths
    @EndSegments
    @UnevenDiagonalsArtStyle
  ]
  
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArtDiagonals
