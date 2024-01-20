LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
PAE = PAA.Practice.PixelArtEvaluation
Jaggies2 = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.Jaggies2

class Jaggies2.Instructions
  class @InstructionStep extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
    @assetClass: -> Jaggies2
    
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
    
    @getPixelArtEvaluation: ->
      drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
    
    getTutorialStep: (stepNumber) ->
      return unless asset = @getActiveAsset()

      stepNumber ?= @constructor.stepNumber()

      asset.stepAreas()[0].steps()[stepNumber - 1]
    
    impliedLineMarkupForStep: (asset, pixelArtEvaluation, stepNumber) ->
      markup = []
      lines = []
      
      step = asset.stepAreas()[0].steps()[stepNumber - 1]
      
      for point in step.goalPixels
        lines.push line for line in pixelArtEvaluation.getLinesAt(point.x, point.y) when line not in lines
      
      for line in lines
        markup.push Markup.PixelArt.impliedLine line
      
      markup
      
    doublesMarkup: (pixelArtEvaluation, point) ->
      markup = []
      lines = pixelArtEvaluation.getLinesAt point.x, point.y
      
      for line in lines
        markup.push Markup.PixelArt.pixelPerfectLineErrors(line)...
      
      markup
    
  class @Line1 extends @InstructionStep
    @id: -> "#{Jaggies2.id()}.Line1"
    @stepNumber: -> 1
    
    @message: -> """
      Pixel art lines are constructed out of multiple rows (or columns) of pixels that usually touch only in corners.
    """
    
    @initialize()
  
  class @Line2Draw extends @InstructionStep
    @id: -> "#{Jaggies2.id()}.Line2Draw"
    @stepNumber: -> 2
    
    @message: -> """
      However, when we draw lines freehand, we often unintentionally cross over multiple neighbors where the rows connect.
    """
    
    @initialize()

  class @Line2Fix extends @InstructionStep
    @id: -> "#{Jaggies2.id()}.Line2Fix"
    @stepNumber: -> 3
    
    @message: -> """
      These unintentional corners are also referred to as 'doubles' since we only need one of them for a minimal line.
      Remove one pixel in each of the doubles.
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      @doublesMarkup pixelArtEvaluation, {x: 3, y:9}
  
  class @Line3Draw extends @InstructionStep
    @id: -> "#{Jaggies2.id()}.Line3Draw"
    @stepNumber: -> 4
    
    @message: -> """
      Doubles create jaggies (sharp corners) also on a conceptual level if we imagine how we perceive the flow of the line.
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      @impliedLineMarkupForStep asset, pixelArtEvaluation, 4
  
  class @Line3Fix extends @InstructionStep
    @id: -> "#{Jaggies2.id()}.Line3Fix"
    @stepNumber: -> 5
    
    @message: -> """
      Remove one of the doubles here as well.
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      [
        @doublesMarkup(pixelArtEvaluation, {x: 3, y:14})...
        @impliedLineMarkupForStep(asset, pixelArtEvaluation, 4)...
      ]
  
  class @Line4Draw extends @InstructionStep
    @id: -> "#{Jaggies2.id()}.Line4Draw"
    @stepNumber: -> 6
    
    @message: -> """
      Even without doubles, certain patterns of line segments lead to jaggies in the perceived lines.
      Pixel artists nowadays mostly use the term jaggies to describe these undesired pixels.
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = for stepNumber in [4, 6]
        @impliedLineMarkupForStep asset, pixelArtEvaluation, stepNumber
      
      _.flatten markup
  
  class @Line4Fix extends @InstructionStep
    @id: -> "#{Jaggies2.id()}.Line4Fix"
    @stepNumber: -> 7
    
    @message: -> """
      Move the pixel to eliminate the problem. We will expand on this later in the tutorial on pixel art curves.
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = for stepNumber in [4, 6]
        @impliedLineMarkupForStep asset, pixelArtEvaluation, stepNumber
        
      markup = _.flatten markup
      
      bitmap = asset.bitmap()
      
      unless bitmap.findPixelAtAbsoluteCoordinates 25, 6
        markupStyle = Markup.errorStyle()
        
        arrowBase =
          arrow:
            end: true
            width: 0.5
            length: 0.25
          style: markupStyle
        
        markup.push
          line: _.extend {}, arrowBase,
            points: [
              x: 25.5, y: 7.5
            ,
              x: 25.5, y: 7.5 - @constructor.movePixelArrowLength
            ]
        
      markup
  
  class @Line5Draw extends @InstructionStep
    @id: -> "#{Jaggies2.id()}.Line5Draw"
    @stepNumber: -> 8
    
    @message: -> """
      Similarly, unwanted jaggies can disrupt the flow of diagonal lines.
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = for stepNumber in [4, 6, 8]
        @impliedLineMarkupForStep asset, pixelArtEvaluation, stepNumber
        
      _.flatten markup
      
  class @Line5Fix extends @InstructionStep
    @id: -> "#{Jaggies2.id()}.Line5Fix"
    @stepNumber: -> 9
    
    @message: -> """
      Move the pixels here as well. This will be explored further in the tutorial on diagonals.
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = for stepNumber in [4, 6, 8]
        @impliedLineMarkupForStep asset, pixelArtEvaluation, stepNumber
        
      markup = _.flatten markup
      
      markupStyle = Markup.errorStyle()
      
      arrowBase =
        arrow:
          end: true
          width: 0.5
          length: 0.25
        style: markupStyle
      
      bitmap = asset.bitmap()
      
      for arrowData in [{x: 23.5, y: 17.5, sign: 1}, {x: 24.5, y: 16.5, sign: 1}, {x: 32.5, y: 10.5, sign: -1}, {x: 33.5, y: 9.5, sign: -1}]
        unless bitmap.findPixelAtAbsoluteCoordinates Math.floor(arrowData.x + arrowData.sign), Math.floor(arrowData.y)
          markup.push
            line: _.extend {}, arrowBase,
              points: [
                x: arrowData.x
                y: arrowData.y
              ,
                x: arrowData.x + arrowData.sign * @constructor.movePixelArrowLength
                y: arrowData.y
              ]
            
      markup
      
  class @Complete extends @InstructionStep
    @id: -> "#{Jaggies2.id()}.Complete"
    
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
      
      markup = for stepNumber in [4, 6, 8]
        @impliedLineMarkupForStep asset, pixelArtEvaluation, stepNumber
      
      _.flatten markup
