AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape extends PAA.Tutorials.Drawing.ElementsOfArt
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.ElementsOfArt.Shape'

  @fullName: -> "Elements of art: shape"

  @initialize()
  
  @assets: -> [
    @BasicShapes
    @CombiningBasicShapes
    @BasicShapesBreakdown
  ]

  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Shape
