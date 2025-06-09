AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Design.ShapeLanguage extends PAA.Tutorials.Drawing.PixelArtTools
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.Design.ShapeLanguage'

  @fullName: -> "Shape language"

  @initialize()

  @assets: -> [
    @Circle2
    @Square2
  ]
  
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.Design.Fundamentals
    chapter.getContent PAA.LearnMode.Design.Fundamentals.Content.DrawingTutorials.ShapeLanguage
