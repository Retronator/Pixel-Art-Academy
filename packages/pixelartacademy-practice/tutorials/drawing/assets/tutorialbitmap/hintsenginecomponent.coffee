PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.HintsEngineComponent
  constructor: (@tutorialBitmap, @drawHintsFunctionName) ->

  drawToContext: (context, renderOptions = {}) ->
    for stepArea in @tutorialBitmap.stepAreas()
      for step in stepArea.steps()[..stepArea.activeStepIndex()]
        step[@drawHintsFunctionName] context, renderOptions
