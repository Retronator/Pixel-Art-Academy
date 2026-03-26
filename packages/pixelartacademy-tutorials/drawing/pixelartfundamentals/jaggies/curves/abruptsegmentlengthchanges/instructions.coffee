LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions
AbruptSegmentLengthChanges = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.AbruptSegmentLengthChanges
Markup = PAA.Practice.Helpers.Drawing.Markup
InterfaceMarking = PAA.PixelPad.Systems.Instructions.InterfaceMarking

class AbruptSegmentLengthChanges.Instructions
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> AbruptSegmentLengthChanges
    
    # The amount of time before we show instructions to the user after a new UI element is introduced.
    @uiRevealDelayDuration = 3
    
    # The amount of time before we show instructions when a new line is introduced.
    @newLineDelayDuration = 5
    
    @getPixelArtEvaluation: ->
      drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
  
    movePixelMarkup: (x, y) ->
      return [] unless asset = @getActiveAsset()
      PAA.Tutorials.Drawing.PixelArtFundamentals.movePixelMarkup asset, x, y, 0, 1
      
    moveFirstPixelMarkup: -> @movePixelMarkup 9, 11
    moveSecondPixelMarkup: -> @movePixelMarkup 11, 4
    
    categoryMarkup: (category) ->
      markupStyle = InterfaceMarking.defaultStyle()
      
      [
        interface:
          selector: ".pixelartacademy-pixelpad-apps-drawing-editor-desktop-pixelartevaluation .category.#{category}"
          delay: 1
          bounds:
            x: -5
            y: -5
            width: 220
            height: 30
          markings: [
            rectangle:
              strokeStyle: markupStyle
              x: -2.5
              y: -0.5
              width: 199
              height: 9
          ]
      ]
  
  class @DrawLine extends @StepInstruction
    @id: -> "#{AbruptSegmentLengthChanges.id()}.DrawLine"
    @stepNumber: -> 1
    
    @message: -> """
      Draw the curve by closely following the intended line. Make it pixel-perfect.
    """
    
    @initialize()

  class @OpenEvaluationPaper extends @StepInstruction
    @id: -> "#{AbruptSegmentLengthChanges.id()}.OpenEvaluationPaper"
    @stepNumber: -> 2
    
    @message: -> """
      You can now open the pixel art evaluation paper to analyze curves.
    """
    
    @initialize()
  
    markup: -> PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.pixelArtEvaluationClickHereMarkup()
  
  class @ReopenEvaluationPaper extends @StepInstruction
    @id: -> "#{AbruptSegmentLengthChanges.id()}.ReopenEvaluationPaper"
    @stepNumbers: -> [3, 7, 8, 12]
    
    @message: -> """
      Open the pixel art evaluation paper to continue.
    """
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show if the pixel art evaluation paper is not open.
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      not pixelArtEvaluation.active()
    
    @priority: -> 2
    
    @initialize()
    
  class @AnalyzeTheCurve extends @StepInstruction
    @id: -> "#{AbruptSegmentLengthChanges.id()}.AnalyzeTheCurve"
    @stepNumber: -> 3
    
    @message: -> """
      To see the lengths of curve segments, hover over the line.
    """
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration

    @initialize()
    
    onActivate: ->
      super arguments...
      
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()
      
      camera.translateTo {x: 15, y: 20}, 1
      camera.scaleTo 8, 1
    
    markup: ->
      markup = []
      
      arrowBase = Markup.arrowBase()
      textBase = Markup.textBase()
      
      markup.push
        line: _.extend {}, arrowBase,
          points: [
            x: 19.5, y: 16.5
          ,
            x: 18.5, y: 18.5, bezierControlPoints: [
              x: 19.5, y: 18
            ,
              x: 18.75, y: 18.25
            ]
          ]
        text: _.extend {}, textBase,
          position:
            x: 19.5, y: 16, origin: Markup.TextOriginPosition.BottomCenter
          value: "hover here"
      
      markup
      
  class @FirstLineAnalysis extends @StepInstruction
    @id: -> "#{AbruptSegmentLengthChanges.id()}.FirstLineAnalysis"
    @stepNumber: -> 4
    
    @message: -> """
      This curve's segments gradually increase and decrease in length, leading to a smooth look.

      Close the evaluation paper and draw the next line.
    """
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    
    @initialize()
  
  class @DrawSecondLine extends @StepInstruction
    @id: -> "#{AbruptSegmentLengthChanges.id()}.DrawSecondLine"
    @stepNumber: -> 5
    
    @message: -> """
      Draw a pixel-perfect line that closely follows the intended line.
    """
    
    @delayDuration: -> @newLineDelayDuration
    
    @initialize()
    
  class @OpenEvaluationPaperSecondLine extends @StepInstruction
    @id: -> "#{AbruptSegmentLengthChanges.id()}.OpenEvaluationPaperSecondLine"
    @stepNumbers: -> [6, 11]
    
    @message: -> """
      Open the evaluation paper and analyze the segment lengths.
    """
    
    @initialize()
    
  class @OpenSmoothCurves extends @StepInstruction
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show if the pixel art evaluation paper is not on the smooth curves criterion.
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      return unless pixelArtEvaluation.active()
      pixelArtEvaluation.activeCriterion() isnt PAE.Criteria.SmoothCurves
    
    markup: -> PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.pixelArtEvaluationClickHereCriterionMarkup '.smooth-curves'
  
  class @OpenSmoothCurvesSecondLine extends @OpenSmoothCurves
    @id: -> "#{AbruptSegmentLengthChanges.id()}.OpenSmoothCurvesSecondLine"
    @stepNumber: -> 7
    
    @message: -> """
      This curve's segments can be improved.

      Click on the Smooth curves criterion to continue.
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()
      
      camera.translateTo {x: 15, y: 12}, 1
      camera.scaleTo 8, 1

  class @ReopenSmoothCurves extends @OpenSmoothCurves
    @id: -> "#{AbruptSegmentLengthChanges.id()}.ReopenSmoothCurves"
    @stepNumbers: -> [8, 13]
    
    @message: -> """
      Click on the Smooth curves criterion to continue.
    """
    
    @priority: -> 1
    
    @initialize()
  
  class @MajorAbruptSegmentLengthChange extends @StepInstruction
    @id: -> "#{AbruptSegmentLengthChanges.id()}.MajorAbruptSegmentLengthChange"
    @stepNumber: -> 8
    
    @activeDisplayState: -> InstructionsSystem.DisplayState.Open
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration
    
    @message: -> """
      There is an abrupt change in segment lengths 2→6, due to the repeating 2 beforehand (2-2-6).
      Major jumps can always be improved by trading pixels from the longer to the shorter segment (2-3-5).

      Close the evaluation paper and smoothen the curve.
    """
    
    @priority: -> 1
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      return unless linePart = pixelArtEvaluation.getLinePartsAt(3, 15)[0]
      
      markup = []
      markup.push @moveFirstPixelMarkup()...
      markup.push Markup.PixelArt.pointSegmentLengthTexts(linePart)...
      markup
      
  class @SecondCurveFix extends @StepInstruction
    @id: -> "#{AbruptSegmentLengthChanges.id()}.SecondCurveFix"
    @stepNumber: -> 9
    
    @activeDisplayState: ->
      # We only have markup without a message.
      InstructionsSystem.DisplayState.Hidden
      
    @initialize()
    
    markup: ->
      return unless @getActiveAsset()
      @moveFirstPixelMarkup()
  
  class @OpenSmoothCurvesThirdLine extends @OpenSmoothCurves
    @id: -> "#{AbruptSegmentLengthChanges.id()}.OpenSmoothCurvesThirdLine"
    @stepNumber: -> 12
    
    @message: -> """
      Click on the Smooth curves criterion to continue.
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()
      
      camera.translateTo {x: 15, y: 5}, 1
      camera.scaleTo 8, 1
  
  class @MinorAbruptSegmentLengthChange extends @StepInstruction
    @id: -> "#{AbruptSegmentLengthChanges.id()}.MinorAbruptSegmentLengthChange"
    @stepNumber: -> 13
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration
    
    @message: -> """
      With longer segments and smaller length changes, this is only a minor problem.
      It can still be improved in the same manner.

      Close the evaluation paper and smoothen the curve.
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      return unless linePart = pixelArtEvaluation.getLinePartsAt(3, 7)[0]
      
      markup = []
      markup.push @moveSecondPixelMarkup()...
      markup.push Markup.PixelArt.pointSegmentLengthTexts(linePart)...
      markup
  
  class @ThirdCurveFix extends @StepInstruction
    @id: -> "#{AbruptSegmentLengthChanges.id()}.ThirdCurveFix"
    @stepNumber: -> 14
    
    @activeDisplayState: ->
      # We only have markup without a message.
      InstructionsSystem.DisplayState.Hidden
      
    @initialize()
    
    markup: -> @moveSecondPixelMarkup()
      
  class @Complete extends PAA.Tutorials.Drawing.Instructions.CompletedInstruction
    @id: -> "#{AbruptSegmentLengthChanges.id()}.Complete"
    @assetClass: -> AbruptSegmentLengthChanges
    
    @message: -> """
      Good job! These curves are as smooth as it gets but know that having the smoothest possible curves can be unnecessary if following precise shapes or placement is more important.
      Use your artistic sense to choose whether the evaluation is appropriate for the needed curves.
    """
    
    @initialize()
    
    displaySide: ->
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
