AE = Artificial.Everywhere
AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.PixelsWithPathsStep extends TutorialBitmap.PixelsStep
  constructor: ->
    super arguments...
    
    @options.drawHintsForGoalPixels = false
    @options.hintStrokeWidth ?= 1
    
    @paths = for svgPath in @options.svgPaths
      new TutorialBitmap.PathStep.Path @tutorialBitmap, @, svgPath
  
  drawUnderlyingHints: (context, renderOptions) ->
    TutorialBitmap.PathStep.drawPathFillHints context, renderOptions, @stepArea, @paths

  drawOverlaidHints: (context, renderOptions) ->
    TutorialBitmap.PathStep.drawPathStrokeHints context, renderOptions, @stepArea, @paths, @options.hintStrokeWidth
