AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.PortfolioComponent extends PAA.Practice.Project.Asset.Bitmap.PortfolioComponent
  @register 'PixelArtAcademy.Practice.Tutorials.Drawing.Assets.TutorialBitmap.PortfolioComponent'

  constructor: (@tutorialBitmap) ->
    super arguments...
  
  letterGrade: ->
    return unless pixelArtEvaluation = @tutorialBitmap.bitmap()?.properties?.pixelArtEvaluation
    return unless pixelArtEvaluation.score?
    PAA.Practice.PixelArtEvaluation.getLetterGrade pixelArtEvaluation.score
