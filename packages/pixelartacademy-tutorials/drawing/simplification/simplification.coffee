AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Simplification extends PAA.Practice.Tutorials.Drawing.Tutorial
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.Simplification'

  @fullName: -> "Simplification"

  @initialize()

  @assets: -> [
    @Symbols
    @SymbolicAndRealisticDrawing
    @Silhouette
    @DefiningFeatures
    @StylizedProportions
    @BasicShapes
    @IntentionalSimplification
  ]
  
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Simplification
