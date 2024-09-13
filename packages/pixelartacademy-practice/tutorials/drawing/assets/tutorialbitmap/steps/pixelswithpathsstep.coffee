AE = Artificial.Everywhere
AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.PixelsWithPathsStep extends TutorialBitmap.PixelsStep
  constructor: ->
    super arguments...
    
    @options.drawHintsForGoalPixels = false
    
    @paths = for svgPath in @options.svgPaths
      new TutorialBitmap.PathStep.Path @tutorialBitmap, @, svgPath
  
  drawUnderlyingHints: (context, renderOptions) ->
    TutorialBitmap.PathStep.drawUnderlyingHints context, renderOptions, @stepArea, @paths
