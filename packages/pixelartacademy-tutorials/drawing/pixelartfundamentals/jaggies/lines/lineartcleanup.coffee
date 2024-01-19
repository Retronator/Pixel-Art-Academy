LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
Markup = PAA.Practice.Helpers.Drawing.Markup

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.LineartCleanup extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.LineartCleanup"
  
  @displayName: -> "Lineart cleanup"
  
  @description: -> """
    Practice cleaning up doubles.
  """
  
  @fixedDimensions: -> width: 40, height: 30
  
  @resources: ->
    startPixels: new @Resource.ImagePixels "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/lines/lineartcleanup.png"
  
  @markup: -> true
  @pixelArtEvaluation: -> true
  
  @initialize()
  
  Asset = @
  
  initializeSteps: ->
    super arguments...
    
    fixedDimensions = @constructor.fixedDimensions()
    
    stepAreaBounds =
      x: 0
      y: 0
      width: fixedDimensions.width
      height: fixedDimensions.height
    
    stepArea = new @constructor.StepArea @, stepAreaBounds
    
    # Step 1 requires you to connect all the start pixels.
    new @constructor.Steps.DrawLine @, stepArea,
      startPixels: @resources.startPixels
      goalPixels: @resources.startPixels
      
    # Step 2 requires you to open the evaluation paper.
    new @constructor.Steps.OpenEvaluationPaper @, stepArea
    
    # Step 3 requires you to close the evaluation paper.
    new @constructor.Steps.CloseEvaluationPaper @, stepArea
    
    # Step 4 requires you to clean up the line of all doubles.
    new @constructor.Steps.CleanLine @, stepArea,
      goalPixels: @resources.startPixels
  
  class @Steps
    class @DrawLine extends TutorialBitmap.PixelsStep
      @preserveCompleted: -> true
  
      hasPixel: ->
        # Allow drawing everywhere.
        true
        
      completed: ->
        return unless super arguments...
        
        # There needs to be a line that goes through all goal pixels.
        return unless pixelArtEvaluation = @tutorialBitmap.pixelArtEvaluation()
        pixelArtEvaluation.getLinesBetween(@goalPixels...)[0]
        
    class @OpenEvaluationPaper extends TutorialBitmap.EphemeralStep
      activate: ->
        super arguments...
        
        # Execute action with a delay so that the current stroke action has time to complete and the pixel art evaluation
        # gets updated. Otherwise the pixel art evaluation property would get overwritten with old data.
        Meteor.setTimeout =>
          bitmap = @tutorialBitmap.bitmap()
          
          pixelArtEvaluation =
            pixelArtScaling: true
            pixelPerfectLines: {}
          
          updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @tutorialBitmap.constructor.id(), bitmap, 'pixelArtEvaluation', pixelArtEvaluation
          
          bitmap.executeAction updatePropertyAction
        ,
          1000
        
      completed: ->
        return true if super arguments...
        
        drawingEditor = @getEditor()
        return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
        pixelArtEvaluation.active()
    
    class @CloseEvaluationPaper extends TutorialBitmap.EphemeralStep
      completed: ->
        return true if super arguments...
        
        drawingEditor = @getEditor()
        return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
        not pixelArtEvaluation.active()

    class @CleanLine extends TutorialBitmap.PixelsStep
      completed: ->
        return unless super arguments...
        
        # There needs to be a line that goes through all goal pixels.
        return unless pixelArtEvaluation = @tutorialBitmap.pixelArtEvaluation()
        return unless line = pixelArtEvaluation.getLinesBetween(@goalPixels...)[0]
        
        # The line must not have any doubles.
        lineEvaluation = line.evaluate()
        return unless lineEvaluation.widthType is PAE.Line.WidthType.Thin
        
        true
        
  class @Instructions
    class @InstructionStep extends PAA.Tutorials.Drawing.Instructions.Instruction
      @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
      @assetClass: -> Asset
      
      # The amount of time before we show instructions to the user after a new UI element is introduced.
      @uiRevealDelayDuration = 3
      
      @activeConditions: ->
        return unless asset = @getActiveAsset()
        
        # Show with the correct step.
        return unless asset.stepAreas()[0]?.activeStepIndex() is @stepNumber() - 1
        
        # Show until the asset is completed.
        not asset.completed()
      
      @resetDelayOnOperationExecuted: -> true
      
    class @DrawCurve extends @InstructionStep
      @id: -> "#{Asset.id()}.DrawCurve"
      @stepNumber: -> 1
      
      @message: -> """
        Undesirable doubles are an issue when drawing lines freehand. Connect all the pixels by drawing a curve through them with a single, freehand stroke.
      """
      
      @initialize()
    
    class @OpenEvaluationPaper extends @InstructionStep
      @id: -> "#{Asset.id()}.OpenEvaluationPaper"
      @stepNumber: -> 2
      
      @message: -> """
        You can now open the pixel art evaluation paper in the bottom-right corner to get an analysis of your line.
      """
      
      @initialize()
      
    class @CloseEvaluationPaper extends @InstructionStep
      @id: -> "#{Asset.id()}.CloseEvaluationPaper"
      @stepNumber: -> 3
      
      @message: -> """
        Lines are considered 'pixel-perfect' when they don't have any doubles. Close the evaluation paper and improve the line to get to the top grade.
      """
      
      @displaySide: -> InstructionsSystem.DisplaySide.Top
      @delayDuration: -> @uiRevealDelayDuration

      @initialize()

    class @CleanDoubles extends @InstructionStep
      @id: -> "#{Asset.id()}.CleanDoubles"
      @stepNumber: -> 4
      
      @message: -> """
        Remove one pixel in each of the doubles to create a pixel-perfect line.
      """
      
      @delayDuration: -> @defaultDelayDuration
    
      @resetDelayOnOperationExecuted: -> true
    
      @initialize()
    
    class @Complete extends PAA.Tutorials.Drawing.Instructions.Instruction
      @id: -> "#{Asset.id()}.Complete"
      @assetClass: -> Asset
      
      @message: -> """
        Good job! Pixel art software often includes a pixel-perfect option for the pencil, which avoids creation of doubles, but it is important to know how to clean a line by hand too.
      """
  
      @activeConditions: ->
        return unless asset = @getActiveAsset()
        
        # Show when the asset is completed.
        asset.completed()
      
      @initialize()
