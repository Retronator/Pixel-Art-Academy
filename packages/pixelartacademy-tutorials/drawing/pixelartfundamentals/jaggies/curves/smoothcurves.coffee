LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
PAE = PAA.Practice.PixelArtEvaluation

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.SmoothCurves extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.SmoothCurves"

  @displayName: -> "Smooth curves"
  
  @description: -> """
    Learn how you can count pixels to ensure your curves are as smooth as possible.
  """
  
  @fixedDimensions: -> width: 52, height: 40
  
  @steps: ->
    path = '/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/curves/smoothcurves'
    
    [
      goalImageUrl: "#{path}-1-goal.png"
    ,
      goalImageUrl: "#{path}-2.png"
    ,
      goalImageUrl: "#{path}-2-goal.png"
    ,
      goalImageUrl: "#{path}-3-goal.png"
    ,
      imageUrl: "#{path}-4.png"
      goalImageUrl: "#{path}-4-goal.png"
    ]
    
  @markup: -> true
  @pixelArtEvaluation: -> true
  
  @initialize()
  
  initializeSteps: ->
    super arguments...

    stepArea = @stepAreas()[0]
    steps = stepArea.steps()
    
    # Step 2 and 5 introduce extra pixels, so we must allow other steps before them to complete with them present.
    steps[0].options.canCompleteWithExtraPixels = true
    steps[3].options.canCompleteWithExtraPixels = true
    
    # Step 2 needs to behave like a temporary step.
    steps[1].options.preserveCompleted = true
    steps[1].options.hasPixelsWhenInactive = false
    steps[1].options.drawHintsAfterCompleted = false
    
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
    @assetClass: -> Asset
    
    # The length of the arrow to indicate a pixel move.
    @movePixelArrowLength = 1.2
    
    @activeStepNumber: ->
      return unless asset = @getActiveAsset()
      asset.stepAreas()[0].activeStepIndex() + 1
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show with the correct step.
      return unless @activeStepNumber() is @stepNumber()
      
      # Show until the asset is completed.
      not asset.completed()
    
    @resetDelayOnOperationExecuted: -> true
    
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      
      for line in pixelArtEvaluation.layers[0].lines
        # Write segment lengths next to lines.
        markup.push Markup.PixelArt.pointSegmentLengthTexts(line)...
      
      markup
    
  class @Curve1 extends @StepInstruction
    @id: -> "#{Asset.id()}.Curve1"
    @stepNumber: -> 1
    
    @message: -> """
      Pixel art curves appear smooth when the lengths of individual segments change uniformly.
    """
    
    @initialize()
    
  class @Curve2Draw extends @StepInstruction
    @id: -> "#{Asset.id()}.Curve2Draw"
    @stepNumber: -> 2
    
    @message: -> """
      If the lengths alternate between increasing and decreasing, the line appears more jagged.
    """
    
    @initialize()
  
  class @Curve2Fix extends @StepInstruction
    @id: -> "#{Asset.id()}.Curve2Fix"
    @stepNumber: -> 3
    
    @message: -> """
      Move the pixels so that the lengths never decrease (it is OK if the lengths repeat or increase by more than 1).
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      return unless asset = @getActiveAsset()
      bitmap = asset.bitmap()
      
      arrows = [
        {direction: {x: 0, y: -1}, targetPixel: {x: 11, y: 14}}
        {direction: {x: 0, y: -1}, targetPixel: {x: 15, y: 12}}
        {direction: {x: 0, y: 1}, targetPixel: {x: 20, y: 11}}
        {direction: {x: 0, y: 1}, targetPixel: {x: 24, y: 10}}
      ]
      
      markupStyle = Markup.errorStyle()
      
      arrowBase =
        arrow:
          end: true
          width: 0.5
          length: 0.25
        style: markupStyle
      
      for arrow in arrows when not bitmap.findPixelAtAbsoluteCoordinates arrow.targetPixel.x, arrow.targetPixel.y
        fromPosition =
          x: arrow.targetPixel.x - arrow.direction.x + 0.5
          y: arrow.targetPixel.y - arrow.direction.y + 0.5
        
        toPosition =
          x: fromPosition.x + arrow.direction.x * @constructor.movePixelArrowLength
          y: fromPosition.y + arrow.direction.y * @constructor.movePixelArrowLength
        
        markup.push
          line: _.extend {}, arrowBase,
            points: [fromPosition, toPosition]
      
      markup
  
  class @Curve3 extends @StepInstruction
    @id: -> "#{Asset.id()}.Curve3"
    @stepNumber: -> 4
    
    @message: -> """
      Longer curves will change between increasing and decreasing lengths but will do so as few times as possible.
    """
    
    @initialize()
  
  class @Curve4 extends @StepInstruction
    @id: -> "#{Asset.id()}.Curve4"
    @stepNumber: -> 5
    
    @message: -> """
      Freehand curves will often have correct general placement but need to have their segment lengths improved to get a smoother result.
    """
    
    @initialize()

  class @Complete extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @activeDisplayState: ->
      # We only have markup without a message.
      PAA.PixelPad.Systems.Instructions.DisplayState.Hidden
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      
      for line in pixelArtEvaluation.layers[0].lines
        # Write segment lengths next to lines.
        markup.push Markup.PixelArt.pointSegmentLengthTexts(line)...
        
        # Draw perceived curves.
        markup.push Markup.PixelArt.perceivedCurve linePart for linePart in line.parts when linePart instanceof PAE.Line.Part.Curve
      
      markup
