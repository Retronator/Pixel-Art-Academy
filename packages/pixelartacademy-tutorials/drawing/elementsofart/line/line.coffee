AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line extends PAA.Tutorials.Drawing.ElementsOfArt
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.ElementsOfArt.Line'

  @fullName: -> "Elements of art: line"

  @initialize()
  
  @assets: -> [
    @StraightLines
    @CurvedLines
    @BrokenLines
    @BrokenLines2
    @Outlines
    @Outlines2
    @Edges
    @Patterns
  ]

  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Line
