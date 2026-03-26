LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions
InterfaceMarking = PAA.PixelPad.Systems.Instructions.InterfaceMarking
PixelArtFundamentals = PAA.Tutorials.Drawing.PixelArtFundamentals
EndSegments = PixelArtFundamentals.Jaggies.Diagonals.EndSegments
Markup = PAA.Practice.Helpers.Drawing.Markup
StraightLine = PAE.Line.Part.StraightLine

class EndSegments.Instructions
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> EndSegments
    
    @getPixelArtEvaluation: ->
      return unless drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      
    displaySide: ->
      return unless pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom

    openEvaluationPaper: (focusPoint, scale, criterion) ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      pixelArtEvaluation.activate criterion
      
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()
      camera.translateTo focusPoint, 1
      camera.scaleTo scale, 1
      
  class @DrawLine extends @StepInstruction
    @id: -> "#{EndSegments.id()}.DrawLine"
    @stepNumbers: -> [1, 2]
    
    @message: -> """
      Connect the two dots with a line using the default Bresenham algorithm (shift + click without using the even diagonals option).
    """
    
    @initialize()
    
  class @OpenEvaluationPaper extends @StepInstruction
    @id: -> "#{EndSegments.id()}.OpenEvaluationPaper"
    @stepNumber: -> 3
    
    @message: -> """
      Open the pixel art evaluation paper to continue.
    """
    
    @priority: -> 1
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show if the pixel art evaluation paper is not open.
      return unless pixelArtEvaluation = @getPixelArtEvaluation()
      not pixelArtEvaluation.active()
    
    @initialize()
  
  class @OpenEvenDiagonals extends @StepInstruction
    @id: -> "#{EndSegments.id()}.OpenEvenDiagonals"
    @stepNumber: -> 3
    
    @message: -> """
      This line has even segments in the middle, but the shorter ends appear at a slightly different angle.
      
      Open the Even diagonals criterion to analyze the scoring.
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      @openEvaluationPaper {x: 31, y: 5}, 4
    
    markup: ->
      # Show only on the pixel art evaluation overview.
      return [] unless pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      return [] if pixelArtEvaluation.activeCriterion()
      
      markup = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.pixelArtEvaluationClickHereCriterionMarkup '.even-diagonals'
      markup[0].interface.delay = 5
      markup
  
  class @EndSegmentsCriterion extends @StepInstruction
    @id: -> "#{EndSegments.id()}.EndSegmentsCriterion"
    @stepNumber: -> 4
    
    @message: -> """
      The End segments criterion scores the line down for having shorter end segments.

      Make the segments match by lengthening the end and shortening the middle segments.
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      @openEvaluationPaper {x: 31, y: 5}, 4, PAE.Criteria.EvenDiagonals
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      linePart = pixelArtEvaluation.getLinePartsAt(3,7)[0]
      markup = Markup.PixelArt.straightLineBreakdown linePart, asset.bitmap().properties.pixelArtEvaluation
      
      markupStyle = InterfaceMarking.defaultStyle()
      
      if @constructor.getPixelArtEvaluation()?.activeCriterion() is PAE.Criteria.EvenDiagonals
        markup.push
          interface:
            selector: ".pixelartacademy-pixelpad-apps-drawing-editor-desktop-pixelartevaluation .end-segments"
            delay: 1
            bounds:
              x: -10
              y: -10
              width: 210
              height: 50
            markings: [
              rectangle:
                strokeStyle: markupStyle
                x: -2.5
                y: 3
                width: 199
                height: 25
            ]
        
      markup

  class @FixLine extends @StepInstruction
    @id: -> "#{EndSegments.id()}.FixLine"
    @stepNumber: -> 5
    
    @activeDisplayState: ->
      # We only have markup without a message.
      InstructionsSystem.DisplayState.Hidden
    
    @initialize()
    
    movePixelMarkup: (x, y, dx, dy) ->
      return [] unless asset = @getActiveAsset()
      PixelArtFundamentals.movePixelMarkup asset, x, y, dx, dy
    
    markup: ->
      markup = []
      markup.push @movePixelMarkup(x, 6, 0, 1)... for x in [11..13]
      markup.push @movePixelMarkup(25, 5, 0, 1)...
      markup.push @movePixelMarkup(x, 5, 0, -1)... for x in [37..38]
      markup.push @movePixelMarkup(x, 4, 0, -1)... for x in [49..52]
      markup
  
  class @NewScore extends @StepInstruction
    @id: -> "#{EndSegments.id()}.NewScore"
    @stepNumber: -> 6
    
    @message: -> """
      Even though the line now has alternating segments, they are long enough that this isn't as relevant as having matching end segments.

      Close the evaluation paper to continue.
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      @openEvaluationPaper {x: 31, y: 5}, 4, PAE.Criteria.EvenDiagonals
      
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      linePart = pixelArtEvaluation.getLinePartsAt(3,7)[0]
      Markup.PixelArt.straightLineBreakdown linePart, asset.bitmap().properties.pixelArtEvaluation
  
  class @DrawLineTrick extends @StepInstruction
    @id: -> "#{EndSegments.id()}.DrawLineTrick"
    @stepNumbers: -> [7, 8]
    
    @message: -> """
      A small trick to draw long diagonals with the usual line drawing algorithm is to start more inwards. Connect the two dots.
    """
    
    @initialize()
    
    onActivate: ->
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      camera = pixelCanvas.camera()
      camera.translateTo {x: 31, y: 19}, 1
    
  class @DrawLineExtension extends @StepInstruction
    @id: -> "#{EndSegments.id()}.DrawLineExtension"
    @stepNumber: -> 9
    
    @message: -> """
      Now you can extend the end segments to arrive at the same line.
    """
    
    @initialize()
