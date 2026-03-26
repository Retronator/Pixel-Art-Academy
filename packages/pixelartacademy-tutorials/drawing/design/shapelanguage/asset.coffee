LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Design.ShapeLanguage.Asset extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.Design.ShapeLanguage.#{_.pascalCase @displayName()}"

  @lessonFileName: -> _.toLower _.pascalCase @displayName()
  
  @createResourceUrl: (fileName) -> "/pixelartacademy/tutorials/drawing/design/shapelanguage/#{fileName}"
  @createLessonResourceUrl: (fileName) -> @createResourceUrl "#{@lessonFileName()}-#{fileName}"
