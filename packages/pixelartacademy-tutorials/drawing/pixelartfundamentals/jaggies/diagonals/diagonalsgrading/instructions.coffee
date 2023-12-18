LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
PAG = PAA.Practice.PixelArtGrading
StraightLine = PAG.Line.Part.StraightLine

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions

DiagonalsGrading = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.DiagonalsGrading

class DiagonalsGrading.Instructions
  class @InstructionStep extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
    @assetClass: -> DiagonalsGrading

    # The amount of time before we show instructions to the user after a new UI element is introduced.
    @uiRevealDelayDuration = 4
    
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
    
    @closeOutsideGradingSheet: -> false
    
    @activeDisplayState: ->
      return PAA.PixelPad.Systems.Instructions.DisplayState.Open unless @closeOutsideGradingSheet()
      
      drawingEditor = @getEditor()
      pixelArtGrading = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading
      
      if pixelArtGrading.active() then PAA.PixelPad.Systems.Instructions.DisplayState.Open else PAA.PixelPad.Systems.Instructions.DisplayState.Closed
    
    getTutorialStep: (stepNumber) ->
      return unless asset = @getActiveAsset()

      stepNumber ?= @constructor.stepNumber()

      asset.stepAreas()[0].steps()[stepNumber - 1]
    
    displaySide: ->
      drawingEditor = @getEditor()
      pixelArtGrading = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading

      if pixelArtGrading.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
      
    openGradingSheet: (focusPoint, scale, criterion = PAG.Criteria.EvenDiagonals) ->
      drawingEditor = @getEditor()
      pixelArtGrading = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading
      pixelArtGrading.activate criterion
      
      return unless focusPoint or scale
      
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      pixelCanvas.triggerSmoothMovement()
      
      camera = pixelCanvas.camera()

      if focusPoint
        originDataField = camera.originData()
        originDataField.value focusPoint
        
      if scale
        scaleDataField = camera.scaleData()
        scaleDataField.value scale
        
    centerFocus: ->
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      pixelCanvas.triggerSmoothMovement()
      
      camera = pixelCanvas.camera()
      
      originDataField = camera.originData()
      originDataField.value x: 15, y: 14.5
    
    getLineBreakdownMarkup: (stepNumber) ->
      return [] unless asset = @getActiveAsset()
      return [] unless pixelArtGrading = asset.pixelArtGrading()
      return [] unless step = @getTutorialStep stepNumber
      
      corners = _.flatten step.paths[0].cornersOfParts
      return [] unless linePart = pixelArtGrading.getLinePartsBetween(corners...)[0]
      return [] unless linePart instanceof StraightLine
      
      Markup.PixelArt.straightLineBreakdown linePart
  
  class @GradingSheet extends @InstructionStep
    @id: -> "#{DiagonalsGrading.id()}.GradingSheet"
    @stepNumbers: -> [1, 2]
    
    @message: -> """
      Draw the diagonal and open the pixel art grading sheet in the bottom-right corner.
    """
    
    @initialize()
  
  class @Criterion extends @InstructionStep
    @id: -> "#{DiagonalsGrading.id()}.Criterion"
    @stepNumber: -> 3
    
    @message: -> """
      You can now analyze how even your diagonals are. Click on the Even diagonals criterion to continue.
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
  
  class @Broken extends @InstructionStep
    @id: -> "#{DiagonalsGrading.id()}.Broken"
    @stepNumber: -> 4
    
    @message: -> """
      This diagonal is not even. Further, the single and double segments are broken up into groups instead of nicely alternating.
      
      Hover over the line to see segment length numbers.
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openGradingSheet {x: 15, y: 18}, 4
  
  class @Alternating extends @InstructionStep
    @id: -> "#{DiagonalsGrading.id()}.Alternating"
    @stepNumber: -> 5
    
    @message: -> """
      It's possible to make this line alternate between double and single segments (pattern 2-1-2-1-2-…). Close the grading sheet and change the pixels to follow that pattern.
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @closeOutsideGradingSheet: -> true
    
    @initialize()
  
  class @Alternating23 extends @InstructionStep
    @id: -> "#{DiagonalsGrading.id()}.Alternating23"
    @stepNumber: -> 6
    
    @message: -> """
      Nice! This diagonal now consistently drops 3 pixels for every 2 across, making it the ideal 3:2 diagonal.
      Close the grading sheet to draw the next line.
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openGradingSheet {x: 15, y: 18}, 4
    
    markup: -> @getLineBreakdownMarkup 1
  
  class @ContinueLine2 extends @InstructionStep
    @id: -> "#{DiagonalsGrading.id()}.ContinueLine2"
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
    @id: -> "#{DiagonalsGrading.id()}.Alternating25"
    @stepNumbers: -> [8, 9]
    
    @message: -> """
      This diagonal consists of segments with lengths 2 and 3.
      However, they are again broken up into groups instead of alternating.
      See if you can fix this by using a 2-3-2-3-2-… pattern.
    """
    
    @closeOutsideGradingSheet: -> true
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openGradingSheet {x: 15, y: 10}, 4
    
    markup: ->
      return unless @constructor.activeStepNumber() is 8
      @getLineBreakdownMarkup 7
  
  class @Alternating25Fixed extends @InstructionStep
    @id: -> "#{DiagonalsGrading.id()}.Alternating24Fixed"
    @stepNumber: -> 10
    
    @message: -> """
      The percentage score for this line is higher than for the previous one because the segments are longer, which makes alternating less noticeable.
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openGradingSheet {x: 15, y: 10}, 4
      
    markup: ->
      [@getLineBreakdownMarkup(1)..., @getLineBreakdownMarkup(7)...]
  
  class @ContinueLine3 extends @InstructionStep
    @id: -> "#{DiagonalsGrading.id()}.ContinueLine3"
    @stepNumber: -> 11
    
    @message: -> """
      Continue by drawing the next line using alternating segment lengths.
    """
    
    @delayDuration: -> @newLineDelayDuration
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @centerFocus()
  
  class @Alternating29 extends @InstructionStep
    @id: -> "#{DiagonalsGrading.id()}.Alternating29"
    @stepNumber: -> 12
    
    @message: -> """
      Fix the line to use the 4-5-4-5-4 pattern of segment lengths.
    """
    
    @delayDuration: -> @newLineDelayDuration
    
    @initialize()
  
  class @Ends extends @InstructionStep
    @id: -> "#{DiagonalsGrading.id()}.Ends"
    @stepNumber: -> 13
    
    @message: -> """
      With long segments it becomes harder to distinguish between even and alternating diagonals, making this less of a consideration.
      What is more relevant is for the end segments to match the length of the middle ones.
    """
    
    @closeOutsideGradingSheet: -> true
    
    @initialize()

    onActivate: ->
      super arguments...
      @openGradingSheet {x: 15, y: 15}, 4
    
    markup: ->
      [@getLineBreakdownMarkup(1)..., @getLineBreakdownMarkup(7)..., @getLineBreakdownMarkup(11)...]
  
  class @ContinueLine4 extends @InstructionStep
    @id: -> "#{DiagonalsGrading.id()}.ContinueLine4"
    @stepNumber: -> 14
    
    @message: -> """
      Continue by drawing the final line.
    """
    
    @delayDuration: -> @newLineDelayDuration
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @centerFocus()
      
  class @Highlight extends @InstructionStep
    @id: -> "#{DiagonalsGrading.id()}.Highlight"
    @stepNumbers: -> [15, 16]
    
    @message: -> """
      The End segments criterion can now help you identify lines that have shorter end segments.
      You can hover over the numbers on the grading sheet to highlight just the lines of that type.
      To finish, improve the line to have end segments match the middle ones.
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @closeOutsideGradingSheet: -> true
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openGradingSheet {x: 15, y: 25}, 4
    
  class @Complete extends @InstructionStep
    @id: -> "#{DiagonalsGrading.id()}.Complete"
    
    @message: -> """
      Well done! You can't further improve the percentage score of this lesson since you're graded on even diagonals while the image requires uneven ones.
      Still, by using alternating segment lengths and matching ends, you earned the top grade.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
      
    @closeOutsideGradingSheet: -> true
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openGradingSheet {x: 15, y: 15}, 3, null
