AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.PortfolioComponent extends PAA.Practice.Project.Asset.Bitmap.PortfolioComponent
  @register 'PixelArtAcademy.Practice.Tutorials.Drawing.Assets.TutorialBitmap.PortfolioComponent'

  constructor: (@tutorialBitmap) ->
    super arguments...
  
  letterGrade: ->
    return unless pixelArtGrading = @tutorialBitmap.bitmap()?.properties?.pixelArtGrading
    PAA.Practice.PixelArtGrading.getLetterGrade pixelArtGrading.score
