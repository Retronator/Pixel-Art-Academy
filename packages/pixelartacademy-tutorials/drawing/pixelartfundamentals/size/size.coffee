AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtFundamentals.Size extends PAA.Tutorials.Drawing.PixelArtFundamentals
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Size'

  @fullName: -> "Pixel art size"

  @initialize()
  
  @assets: -> [
    @DisplayResolution
  ]

  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.Size
