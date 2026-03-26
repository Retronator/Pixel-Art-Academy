LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions
LineArtCleanup = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.LineArtCleanup
Markup = PAA.Practice.Helpers.Drawing.Markup
InterfaceMarking = PAA.PixelPad.Systems.Instructions.InterfaceMarking

class LineArtCleanup.Instructions
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> LineArtCleanup
    
    # The amount of time before we show instructions to the user after a new UI element is introduced.
    @uiRevealDelayDuration = 3
    
    @getPixelArtEvaluation: ->
      drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
    
    displaySide: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
      
  class @DrawLine extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.DrawLine"
    @stepNumber: -> 1
    
    @message: -> """
      Connect all the pixels by drawing a single pixel-perfect curve through them.
    """
    
    @initialize()
  
  class @CleanDoubleAndCorners extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.CleanDoubleAndCorners"
    @stepNumber: -> 1
    
    @message: -> """
      Make the line pixel-perfect (remove all doubles and corners).
    """
    
    @priority: -> 2
    
    @initialize()
    
    activeConditions: ->
      return unless super arguments...
      
      # Show if there are corners and doubles and all dots are covered.
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      return unless step1 = @getTutorialStep 1
      
      bitmap = asset.bitmap()

      for pixel in step1.goalPixels
        return unless bitmap.getPixelForLayerAtCoordinates 0, pixel.x, pixel.y
      
      for line in pixelArtEvaluation.layers[0].lines
        lineEvaluation = line.evaluate LineArtCleanup._pixelPerfectLinesEvaluationProperty
        return true if lineEvaluation.doubles.count or lineEvaluation.corners.count
        
      false
  
  class @OpenEvaluationPaper extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.OpenEvaluationPaper"
    @stepNumber: -> 2
    
    @message: -> """
        You can now open the pixel art evaluation paper to get an analysis of your curves.
      """
    
    @initialize()
  
  class @ReopenEvaluationPaper extends @OpenEvaluationPaper
    @id: -> "#{LineArtCleanup.id()}.ReopenEvaluationPaper"
    @stepNumbers: -> [2, 3, 4]
    
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
    
  class @OpenSmoothCurves extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.OpenSmoothCurves"
    @stepNumbers: -> [3, 4]
    
    @message: -> """
      Click on the Smooth curves criterion to continue.
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show if the pixel art evaluation paper is not on the smooth curves criterion.
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      return unless pixelArtEvaluation.active()
      pixelArtEvaluation.activeCriterion() isnt PAE.Criteria.SmoothCurves
    
    @priority: -> 1
    
    @initialize()
    
    markup: -> PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.pixelArtEvaluationClickHereCriterionMarkup '.smooth-curves'
  
  class @AnalyzeTheCurve extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.AnalyzeTheCurve"
    @stepNumber: -> 4
    
    @message: -> """
      Smooth curves will not have abrupt length changes, straight parts, or frequent inflection points.
      
      Hover over various parts of the evaluation paper to analyze your curve.
    """
    
    @delayDuration: -> @uiRevealDelayDuration

    @initialize()
    
    markup: ->
      markup = []
      
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      markup.push
        interface:
          selector: '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pixelartevaluation'
          delay: 1
          bounds:
            x: 170
            y: 0
            width: 80
            height: 120
          markings: [
            rectangle:
              strokeStyle: markupStyle
              x: 181.5
              y: 29
              width: 20
              height: 80
            line: _.extend {}, arrowBase,
              points: [
                x: 235, y: 49
              ,
                x: 205, y: 66, bezierControlPoints: [
                  x: 235, y: 61
                ,
                  x: 215, y: 66
                ]
              ]
            text: _.extend {}, textBase,
              position:
                x: 235, y: 47, origin: Markup.TextOriginPosition.BottomCenter
              value: "hover\nhere"
          ]
      
      markup
  
  class @SmoothenTheCurve extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.SmoothenTheCurve"
    @stepNumber: -> 5
    
    @message: -> """
      Clean your line until all Smooth curves criteria are improved over 90%.
    """
    
    @delayDuration: -> @defaultDelayDuration
    
    @initialize()

  class @DrawOneCurve extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.DrawOneCurve"
    @assetClass: -> LineArtCleanup
    
    @message: -> """
      Make sure there is only one curve that connects all the required pixels.
    """
    
    @activeConditions: ->
      # Show if there are multiple lines present.
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      pixelArtEvaluation.layers[0].lines.length > 1
    
    @priority: -> 1
    
    @initialize()
