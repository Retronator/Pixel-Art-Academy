PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.HintsEngineComponent
  constructor: (@tutorialBitmap, @drawHintsFunctionName) ->

  drawToContext: (context, renderOptions = {}) ->
    for stepArea in @tutorialBitmap.stepAreas()
      activeStepIndex = stepArea.activeStepIndex()
      steps = stepArea.steps()

      for step, index in steps[..activeStepIndex]
        unless step.drawHintsAfterCompleted()
          if index < activeStepIndex
            continue
            
          else
            # Don't draw hints at the end of the tutorial steps. We don't want to call completed on the
            # step since that would make it recompute. Step area instead has the last computation stored.
            continue if activeStepIndex is steps.length - 1 and stepArea.completed()
        
        step[@drawHintsFunctionName] context, renderOptions
    
    # Explicit return to avoid result collection.
    null
