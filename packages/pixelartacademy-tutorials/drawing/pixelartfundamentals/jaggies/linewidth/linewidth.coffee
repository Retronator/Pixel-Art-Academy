AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth'

  @fullName: -> "Pixel art line width"

  @initialize()
  
  @assets: -> [
    @LineWidth
    @ThinLines
    @ThickLines
    @WideLines
    @VaryingLineWidth
  ]
  
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArtLineWidth
