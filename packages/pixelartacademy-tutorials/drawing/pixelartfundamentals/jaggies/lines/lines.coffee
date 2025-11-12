AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines'

  @fullName: -> "Pixel art lines"

  @initialize()
  
  @assets: -> [
    @IntendedAndPerceivedLines
    @Jaggies
    @Jaggies2
    @LineArtCleanup
    @Corners
  ]

  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.Lines
