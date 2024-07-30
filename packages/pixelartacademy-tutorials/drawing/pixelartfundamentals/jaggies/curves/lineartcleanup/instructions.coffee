LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions
LineArtCleanup = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.LineArtCleanup

class LineArtCleanup.Instructions
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
    @assetClass: -> LineArtCleanup
    
    # The amount of time before we show instructions to the user after a new UI element is introduced.
    @uiRevealDelayDuration = 3
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show with the correct step.
      return unless asset.stepAreas()[0]?.activeStepIndex() is @stepNumber() - 1
      
      # Show until the asset is completed.
      not asset.completed()
    
    @resetDelayOnOperationExecuted: -> true
    
    @getPixelArtEvaluation: ->
      drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
    
    getTutorialStep: (stepNumber) ->
      return unless asset = @getActiveAsset()
      
      stepNumber ?= @constructor.stepNumber()
      
      asset.stepAreas()[0].steps()[stepNumber - 1]
    
  class @DrawLine extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.DrawLine"
    @stepNumber: -> 1
    
    @message: -> """
      Connect all the pixels by drawing a curve through them with a single, freehand stroke, and open the pixel art evaluation paper in the bottom-right corner.
    """
    
    @initialize()
    
    displaySide: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
  
  class @OpenSmoothCurves extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.OpenSmoothCurves"
    @stepNumber: -> 2
    
    @message: -> """
      You can now analyze your curves. Click on the Smooth curves criterion to continue.
    """
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
    
  class @AnalyzeTheCurve extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.AnalyzeTheCurve"
    @stepNumber: -> 3
    
    @message: -> """
      Smooth curves will have uniformly changing segment lengths, minimal straight parts, and as few changes of direction (inflection points) as possible.
      Hover over various parts of the evaluation paper to analyze your curve.
    """
    
    @delayDuration: -> @uiRevealDelayDuration

    @initialize()
    
    displaySide: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
  
  class @SmoothenTheCurve extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.SmoothenTheCurve"
    @stepNumber: -> 4
    
    @message: -> """
      Clean your line until all Smooth curves criteria are improved over 90%.
    """
    
    @delayDuration: -> @defaultDelayDuration
  
    @resetDelayOnOperationExecuted: -> true
    
    @initialize()
    
    displaySide: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
