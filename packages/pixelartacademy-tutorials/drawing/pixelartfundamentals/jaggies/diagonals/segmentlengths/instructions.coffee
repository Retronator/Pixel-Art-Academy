LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
PAE = PAA.Practice.PixelArtEvaluation
StraightLine = PAE.Line.Part.StraightLine

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions

SegmentLengths = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.SegmentLengths

class SegmentLengths.Instructions
  class @PixelPerfectInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{SegmentLengths.id()}.PixelPerfectInstruction"
    @assetClass: -> SegmentLengths
    
    @message: -> """
      Make sure your lines are pixel-perfect (they shouldn't have doubles).
    """
    
    @getPixelArtEvaluation: ->
      return unless drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      
    @_pixelPerfectLinesEvaluationProperty =
      pixelPerfectLines:
        doubles:
          countAllLineWidthTypes: true
          countPointsWithMultiplePixels: true
      
    @activeConditions: ->
      # Only show this tip when the evaluation paper is open.
      return unless pixelArtEvaluationView = @getPixelArtEvaluation()
      return unless pixelArtEvaluationView.active()
      
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()

      for line in pixelArtEvaluation.layers[0].lines
        # The line must not have any doubles.
        lineEvaluation = line.evaluate @_pixelPerfectLinesEvaluationProperty
        return true if lineEvaluation.doubles.count

      false
    
    @priority: -> 1
    
    @initialize()
    
    displaySide: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
    
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> SegmentLengths

    # The amount of time before we show instructions to the user after a new UI element is introduced.
    @uiRevealDelayDuration = 3
    
    # The amount of time before we show instructions when a new line is introduced.
    @newLineDelayDuration = 5
    
    @closeOutsideEvaluationPaper: -> false
    
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @getPixelArtEvaluation: ->
      return unless drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
    
    @activeDisplayState: ->
      return PAA.PixelPad.Systems.Instructions.DisplayState.Open unless @closeOutsideEvaluationPaper()
      
      pixelArtEvaluation = @getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then PAA.PixelPad.Systems.Instructions.DisplayState.Open else PAA.PixelPad.Systems.Instructions.DisplayState.Closed
    
    displaySide: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()

      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
      
    openEvaluationPaper: (focusPoint, scale) ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      pixelArtEvaluation.activate PAE.Criteria.EvenDiagonals
      
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()
      camera.translateTo focusPoint, 1
      camera.scaleTo scale, 1
        
    centerFocus: ->
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()
      camera.translateTo {x: 15, y: 26}, 1
      
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
  
  class @DrawDiagonals extends @StepInstruction
    @id: -> "#{SegmentLengths.id()}.DrawDiagonals"
    @stepNumber: -> 1
    
    @delayDuration: -> @defaultDelayDuration
  
    @message: -> """
      Draw the three diagonals with the pencil's line-drawing capability (shift + click).
    """
    
    @initialize()
  
  class @EvaluationPaper extends @StepInstruction
    @id: -> "#{SegmentLengths.id()}.EvaluationPaper"
    @stepNumber: -> 2
    
    @message: -> """
      You can now open the pixel art evaluation paper to analyze diagonals.
    """
    
    @initialize()

    markup: -> PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.pixelArtEvaluationClickHereMarkup()
  
  class @ReopenEvaluationPaper extends @StepInstruction
    @id: -> "#{SegmentLengths.id()}.ReopenEvaluationPaper"
    @stepNumbers: -> [3, 4]
    
    @message: -> """
      Open the pixel art evaluation paper to continue.
    """
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show if the pixel art evaluation paper is not open.
      return unless pixelArtEvaluation = @getPixelArtEvaluation()
      not pixelArtEvaluation.active()
    
    @priority: -> 2
    
    @initialize()
  
  class @Criterion extends @StepInstruction
    @id: -> "#{SegmentLengths.id()}.Criterion"
    @stepNumber: -> 3
    
    @message: -> """
      Diagonals can be evaluated on how even they are. Click on the Even diagonals criterion to continue.
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
  
    markup: ->
      # Show only on the pixel art evaluation overview.
      return unless pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      return if pixelArtEvaluation.activeCriterion()
      
      PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.pixelArtEvaluationClickHereCriterionMarkup '.even-diagonals'
  
  class @ReopenCriterion extends @StepInstruction
    @id: -> "#{SegmentLengths.id()}.ReopenCriterion"
    @stepNumber: -> 4
    
    @message: -> """
      Click on the Even diagonals criterion to continue.
    """
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show if the pixel art evaluation paper is not on the even diagonals page.
      return unless pixelArtEvaluation = @getPixelArtEvaluation()
      return unless pixelArtEvaluation.active()
      pixelArtEvaluation.activeCriterion() isnt PAE.Criteria.EvenDiagonals
    
    @priority: -> 2
    
    @initialize()
    
  class @TypesMarkup extends @StepInstruction
    markup: ->
      # Show if the pixel art evaluation paper is on the even diagonals page.
      return [] unless pixelArtEvaluationView = @constructor.getPixelArtEvaluation()
      return [] unless pixelArtEvaluationView.activeCriterion() is PAE.Criteria.EvenDiagonals
      
      markup = []
      
      arrowBase = Markup.arrowBase()
      textBase = Markup.textBase()
      
      step = @getTutorialStep 4
      lineStartYsHoveredOver = step.lineStartYsHoveredOver()
      
      unless 32 in lineStartYsHoveredOver
        markup.push
          line: _.extend {}, arrowBase,
            points: [
              x: 30, y: 32
            ,
              x: 24, y: 26.5, bezierControlPoints: [
                x: 30, y: 28.5
              ,
                x: 27, y: 27
              ]
            ]
      
      unless 41 in lineStartYsHoveredOver
        markup.push
          line: _.extend {}, arrowBase,
            points: [
              x: 27, y: 34
            ,
              x: 24, y: 33.5, bezierControlPoints: [
                x: 25, y: 34
              ,
                x: 26, y: 33.5
              ]
            ]
      
      unless 49 in lineStartYsHoveredOver
        markup.push
          line: _.extend {}, arrowBase,
            points: [
              x: 30, y: 36
            ,
              x: 23, y: 41.5, bezierControlPoints: [
                x: 30, y: 39.5
              ,
                x: 27, y: 41
              ]
            ]
            
      unless lineStartYsHoveredOver.length is 3
        markup.push
          text: _.extend {}, textBase,
            position:
              x: 30, y: 34, origin: Markup.TextOriginPosition.MiddleCenter
            value: "hover\nhere"
      
      markup.push
        text: _.extend {}, textBase,
          position:
            x: 4, y: 29.5, origin: Markup.TextOriginPosition.MiddleCenter
          value: "EVEN"
      
      markup.push
        text: _.extend {}, textBase,
          position:
            x: 4, y: 38.5, origin: Markup.TextOriginPosition.MiddleCenter
          value: "UNEVEN\nALTERNATING"

      markup.push
        text: _.extend {}, textBase,
          position:
            x: 4, y: 46.5, origin: Markup.TextOriginPosition.MiddleCenter
          value: "UNEVEN\nBROKEN"
          
      markup
  
  class @Hover extends @TypesMarkup
    @id: -> "#{SegmentLengths.id()}.Hover"
    @stepNumber: -> 4
    
    @message: -> """
      Hover over the diagonals to analyze how even their segment lengths are.
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show if the pixel art evaluation paper is on the even diagonals page.
      return unless pixelArtEvaluation = @getPixelArtEvaluation()
      pixelArtEvaluation.activeCriterion() is PAE.Criteria.EvenDiagonals
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 38}, 4
  
  class @DiagonalOfType extends @TypesMarkup
    @type: -> throw new AE.NotImplementedException "A line of type step must provide the type needed for completion."

    @stepNumbers: -> [4, 5]
    
    @priority: -> 1
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show if the pixel art evaluation paper is on the even diagonals page.
      return unless pixelArtEvaluationView = @getPixelArtEvaluation()
      return unless pixelArtEvaluationView.activeCriterion() is PAE.Criteria.EvenDiagonals
      
      return unless hoveredPixel = pixelArtEvaluationView.hoveredPixel()
      pixelArtEvaluation = pixelArtEvaluationView.pixelArtEvaluation()
      return unless hoveredLinePart = pixelArtEvaluation.getLinePartsAt(hoveredPixel.x, hoveredPixel.y)[0]

      lineEvaluation = hoveredLinePart.evaluate()
      lineEvaluation.segmentLengths.type is @type()
  
  class @EvenDiagonal extends @DiagonalOfType
    @id: -> "#{SegmentLengths.id()}.EvenDiagonal"
    @type: -> StraightLine.SegmentLengths.Even
    
    @message: -> """
      The 1:2 diagonal is even since it only has segments of length 2.
    """
    
    @initialize()
  
  class @AlternatingDiagonal extends @DiagonalOfType
    @id: -> "#{SegmentLengths.id()}.AlternatingDiagonal"
    @type: -> StraightLine.SegmentLengths.Alternating
    
    @message: -> """
      The 2:3 diagonal has perfectly alternating 1 and 2 segments (1-2-1-2 pattern) which is as good as it gets for an uneven diagonal.
    """

    @initialize()
  
  class @BrokenDiagonal extends @DiagonalOfType
    @id: -> "#{SegmentLengths.id()}.BrokenDiagonal"
    @type: -> StraightLine.SegmentLengths.Broken
    
    @message: -> """
      This uneven diagonal's segments are broken into groups of multiple repeating 1s and single 2s (1-1-1-2 pattern), making it visually broken too.
    """
    
    @initialize()
    
  class @CloseEvaluationPaper extends @TypesMarkup
    @id: -> "#{SegmentLengths.id()}.CloseEvaluationPaper"
    @stepNumber: -> 5
    
    @message: -> """
      Close the evaluation paper to draw the next line.
    """
    
    @initialize()
  
  class @ContinueLine2 extends @StepInstruction
    @id: -> "#{SegmentLengths.id()}.ContinueLine2"
    @stepNumber: -> 6
    
    @message: -> """
      Draw the new diagonal with the pencil's line-drawing capability (shift + click).
    """
    
    @delayDuration: -> @newLineDelayDuration
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @centerFocus()
    
  class @Alternating25 extends @StepInstruction
    @id: -> "#{SegmentLengths.id()}.Alternating25"
    @stepNumber: -> 7
    
    @message: -> """
      This diagonal consists of segments with lengths 2 and 3.
      However, they are unnecessarily broken into groups (3-3 and 2-2) instead of alternating.

      See if you can fix this by using a 2-3-2-3-2-… pattern.
    """
    
    @closeOutsideEvaluationPaper: -> true
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 20}, 4
    
    markup: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      return [] unless pixelArtEvaluation.active()
      
      @getLineBreakdownMarkup 7
  
  class @Alternating25Fixed extends @StepInstruction
    @id: -> "#{SegmentLengths.id()}.Alternating25Fixed"
    @stepNumber: -> 8
    
    @message: -> """
      Nice! This diagonal now consistently rises 2 pixels for every 5 across, making it the ideal 2:5 diagonal.

      Continue by drawing the next line using alternating segment lengths.
    """
    
    @closeOutsideEvaluationPaper: -> true
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 20}, 4
    
    markup: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      return [] unless pixelArtEvaluation.active()
      
      @getLineBreakdownMarkup 6
  
  class @ContinueLine3 extends @StepInstruction
    @id: -> "#{SegmentLengths.id()}.ContinueLine3"
    @stepNumber: -> 9
    
    @message: -> """
      Continue by drawing the next line using alternating segment lengths.
    """
    
    @delayDuration: -> @newLineDelayDuration
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @centerFocus()
  
  class @Line3AlternatingHint extends @StepInstruction
    @id: -> "#{SegmentLengths.id()}.Line3AlternatingHint"
    @stepNumber: -> 10
    
    @message: -> """
      Draw the line using a 4-5-4-5-4 pattern of segment lengths.
    """
    
    @delayDuration: -> @newLineDelayDuration
    
    @initialize()
  
  class @Alternating29 extends @StepInstruction
    @id: -> "#{SegmentLengths.id()}.Alternating29"
    @stepNumber: -> 11
    
    @message: -> """
      The percentage score for this line (90%) is higher than the previous one (83%) because the segments are longer, which makes alternating less noticeable.
      
      Finish by drawing an even 1:5 diagonal for comparison.
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 14}, 4
    
    markup: ->
      [@getLineBreakdownMarkup(6)..., @getLineBreakdownMarkup(9)...]

  class @EvenUnevenComparison extends @StepInstruction
    @id: -> "#{SegmentLengths.id()}.EvenUnevenComparison"
    
    @message: -> """
      As segments get longer, the difference between uneven and even diagonals becomes negligible. Well done!
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
      
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 12}, 4
    
    markup: ->
      [@getLineBreakdownMarkup(9)..., @getLineBreakdownMarkup(12)...]
      
  class @Complete extends @StepInstruction
    @id: -> "#{SegmentLengths.id()}.Complete"
    
    @message: -> """
      Note that you can't further improve the percentage score for this lesson since you're graded on even diagonals while the image requires uneven ones too.
      Remember that grades don't matter when the artwork looks the way you want.
    """
    
    @activeDisplayState: ->
      pixelArtEvaluation = @getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then PAA.PixelPad.Systems.Instructions.DisplayState.Hidden else PAA.PixelPad.Systems.Instructions.DisplayState.Open
      
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed and evaluation paper is closed.
      return unless asset.completed()
      
      pixelArtEvaluation = @getPixelArtEvaluation()
      not pixelArtEvaluation.active()
      
    @priority: -> 1
    
    @initialize()
