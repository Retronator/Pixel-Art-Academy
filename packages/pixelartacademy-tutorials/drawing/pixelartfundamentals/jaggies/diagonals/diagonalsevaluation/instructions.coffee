LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
PAE = PAA.Practice.PixelArtEvaluation
StraightLine = PAE.Line.Part.StraightLine

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions

DiagonalsEvaluation = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.DiagonalsEvaluation

class DiagonalsEvaluation.Instructions
  class @InstructionStep extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
    @assetClass: -> DiagonalsEvaluation

    # The amount of time before we show instructions to the user after a new UI element is introduced.
    @uiRevealDelayDuration = 3
    
    # The amount of time before we show instructions when a new line is introduced.
    @newLineDelayDuration = 3
    
    @activeStepNumber: ->
      return unless asset = @getActiveAsset()
      asset.stepAreas()[0].activeStepIndex() + 1
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      stepNumbers = @stepNumbers?() or [@stepNumber()]
      
      # Show with the correct step.
      return unless asset.stepAreas()[0].activeStepIndex() + 1 in stepNumbers
      
      # Show until the asset is completed.
      not asset.completed()
    
    @resetDelayOnOperationExecuted: -> true
    
    @closeOutsideEvaluationPaper: -> false
    
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @getPixelArtEvaluation: ->
      drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
    
    @activeDisplayState: ->
      return PAA.PixelPad.Systems.Instructions.DisplayState.Open unless @closeOutsideEvaluationPaper()
      
      pixelArtEvaluation = @getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then PAA.PixelPad.Systems.Instructions.DisplayState.Open else PAA.PixelPad.Systems.Instructions.DisplayState.Closed
    
    getTutorialStep: (stepNumber) ->
      return unless asset = @getActiveAsset()

      stepNumber ?= @constructor.stepNumber()

      asset.stepAreas()[0].steps()[stepNumber - 1]
    
    displaySide: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()

      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
      
    openEvaluationPaper: (focusPoint, scale, criterion = PAE.Criteria.EvenDiagonals) ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      pixelArtEvaluation.activate criterion
      
      return unless focusPoint or scale
      
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()

      if focusPoint
        camera.translateTo focusPoint, 1
        
      if scale
        camera.scaleTo scale, 1
        
    centerFocus: ->
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()
      camera.translateTo {x: 15, y: 14.5}, 1
      
    getLinePartForStep: (stepNumber) ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      return unless step = @getTutorialStep stepNumber
      
      corners = _.flatten step.paths[0].cornersOfParts
      return unless linePart = pixelArtEvaluation.getLinePartsBetween(corners...)[0]
      return unless linePart instanceof StraightLine
      
      linePart
    
    getLineBreakdownMarkup: (stepNumber) ->
      return [] unless linePart  = @getLinePartForStep stepNumber
      
      Markup.PixelArt.straightLineBreakdown linePart
  
  class @EvaluationPaper extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.EvaluationPaper"
    @stepNumbers: -> [1, 2]
    
    @message: -> """
      Draw the diagonal and open the pixel art evaluation paper in the bottom-right corner.
    """
    
    @initialize()
  
  class @Criterion extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.Criterion"
    @stepNumber: -> 3
    
    @message: -> """
      You can now analyze how even your diagonals are. Click on the Even diagonals criterion to continue.
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
  
  class @Broken extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.Broken"
    @stepNumber: -> 4
    
    @message: -> """
      This diagonal is not even. Further, the single and double segments are broken up into groups instead of nicely alternating.
      
      Hover over the line to see segment length numbers.
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 18}, 4
  
  class @NotBrokenAlternative extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.NotBrokenAlternative"
    @stepNumber: -> 4
    
    @message: -> """
      Hover over the line to see segment length numbers.
    """
    
    @activeConditions: ->
      return false unless super arguments...
      
      # See if we have an alternative diagonal to begin with.
      return unless bitmap = @getActiveAsset().bitmap()
      
      bitmap.properties.pixelArtEvaluation.evenDiagonals.segmentLengths.counts.broken is 0
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @priority: -> 1
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 18}, 4
  
  class @Alternating extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.Alternating"
    @stepNumber: -> 5
    
    @message: -> """
      It's possible to make this line alternate between double and single segments (pattern 2-1-2-1-2-…). Close the evaluation paper and change the pixels to follow that pattern.
    """
    
    @closeOutsideEvaluationPaper: -> true
    
    @initialize()
  
  class @Alternating23 extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.Alternating23"
    @stepNumber: -> 6
    
    @message: -> """
      Nice! This diagonal consistently drops 3 pixels for every 2 across, making it the ideal 3:2 diagonal.
      Close the evaluation paper to draw the next line.
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 18}, 4
    
    markup: -> @getLineBreakdownMarkup 1
  
  class @ContinueLine2 extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.ContinueLine2"
    @stepNumber: -> 7
    
    @message: -> """
      Continue by drawing the next line.
    """
    
    @delayDuration: -> @newLineDelayDuration
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @centerFocus()
    
  class @Alternating25 extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.Alternating25"
    @stepNumber: -> 8
    
    @message: -> """
      This diagonal consists of segments with lengths 2 and 3.
      However, they are again broken up into groups instead of alternating.
      See if you can fix this by using a 2-3-2-3-2-… pattern.
    """
    
    @closeOutsideEvaluationPaper: -> true
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 10}, 4
    
    markup: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      return [] unless pixelArtEvaluation.active()
      
      @getLineBreakdownMarkup 7
  
  class @Alternating25Fixed extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.Alternating24Fixed"
    @stepNumber: -> 9
    
    @message: -> """
      The percentage score for this line is higher than for the previous one because the segments are longer, which makes alternating less noticeable.
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 10}, 4
      
    markup: ->
      [@getLineBreakdownMarkup(1)..., @getLineBreakdownMarkup(7)...]
  
  class @ContinueLine3 extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.ContinueLine3"
    @stepNumber: -> 10
    
    @message: -> """
      Continue by drawing the next line using alternating segment lengths.
    """
    
    @delayDuration: -> @newLineDelayDuration
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @centerFocus()
  
  class @Alternating29 extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.Alternating29"
    @stepNumber: -> 11
    
    @message: -> """
      Fix the line to use the 4-5-4-5-4 pattern of segment lengths.
    """
    
    @delayDuration: -> @newLineDelayDuration
    
    @initialize()
  
  class @Ends extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.Ends"
    @stepNumber: -> 12
    
    @message: -> """
      With long segments it becomes harder to distinguish between even and alternating diagonals, making this less of a consideration.
      What is more relevant is for the end segments to match the length of the middle ones.
    """
    
    @closeOutsideEvaluationPaper: -> true
    
    @initialize()

    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 15}, 4
    
    markup: ->
      [@getLineBreakdownMarkup(1)..., @getLineBreakdownMarkup(7)..., @getLineBreakdownMarkup(11)...]
  
  class @ContinueLine4 extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.ContinueLine4"
    @stepNumber: -> 13
    
    @message: -> """
      Draw the final line with the default Bresenham algorithm (shift + click without using the even diagonals option).
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @centerFocus()
      
  class @Highlight extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.Highlight"
    @stepNumbers: -> [14, 15]
    
    @message: -> """
      The End segments criterion can now help you identify lines that have shorter end segments.
      You can hover over the numbers on the evaluation paper to highlight just the lines of that type.
      To finish, improve the line to have end segments match the middle ones.
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @closeOutsideEvaluationPaper: -> true
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 25}, 4
      
    markup: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      return [] unless pixelArtEvaluation.active()
      return [] unless linePart  = @getLinePartForStep 13
      
      Markup.PixelArt.evaluatedSegmentCornerLines linePart
    
  class @Complete extends @InstructionStep
    @id: -> "#{DiagonalsEvaluation.id()}.Complete"
    
    @message: -> """
      Well done! You can't further improve the percentage score of this lesson since you're evaluated on even diagonals while the image requires uneven ones.
      Still, by using alternating segment lengths and matching ends, you earned the top grade.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
      
    @closeOutsideEvaluationPaper: -> true
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 15}, 3, null
    
    markup: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      return [] unless pixelArtEvaluation.active()
      return [] unless linePart  = @getLinePartForStep 13
      
      Markup.PixelArt.evaluatedSegmentCornerLines linePart
