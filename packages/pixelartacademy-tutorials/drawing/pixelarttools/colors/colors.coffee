AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Colors extends PAA.Tutorials.Drawing.PixelArtTools
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Colors'

  @fullName: -> "Pixel art tools: colors"

  @initialize()
  
  @pacManPaletteName: 'PAC-MAN'

  @assets: -> [
    @ColorSwatches
    @ColorPicking
    @QuickColorPicking
  ]
  
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.Intro.Tutorial
    chapter.getContent PAA.LearnMode.Intro.Tutorial.Content.DrawingTutorials.Colors
