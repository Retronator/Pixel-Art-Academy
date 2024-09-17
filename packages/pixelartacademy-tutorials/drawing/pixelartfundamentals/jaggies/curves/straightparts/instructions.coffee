LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions
StraightParts = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.StraightParts
TextOriginPosition = PAA.Practice.Helpers.Drawing.Markup.TextOriginPosition
Atari2600 = LOI.Assets.Palette.Atari2600
Markup = PAA.Practice.Helpers.Drawing.Markup

class StraightParts.Instructions
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> StraightParts
    
    # The amount of time before we show instructions to the user after a new UI element is introduced.
    @uiRevealDelayDuration = 3
    
    # The amount of time before we show instructions when a new line is introduced.
    @newLineDelayDuration = 5
    
    # The length of the arrow to indicate a pixel move.
    @movePixelArrowLength = 1.2
    
    @getPixelArtEvaluation: ->
      drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
  
    translateAndScaleTo: (x, y, scale) ->
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()
      
      camera.translateTo {x, y}, 1
      camera.scaleTo scale, 1
      
    movePixelMarkup: (x, y, dx, dy) ->
      return [] unless asset = @getActiveAsset()
      bitmap = asset.bitmap()
      
      return [] if bitmap.findPixelAtAbsoluteCoordinates x + dx, y + dy
      
      [
        line:
          arrow:
            end: true
            width: 0.5
            length: 0.25
          style: Markup.errorStyle()
          points: [
            x: x + 0.5, y: y + 0.5
          ,
            x: x + 0.5 + @constructor.movePixelArrowLength * dx, y: y + 0.5 + @constructor.movePixelArrowLength * dy
          ]
      ]
      
    perceivedLinesMarkup: ->
      return [] unless asset = @getActiveAsset()
      return [] unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      
      # Add perceived lines.
      for line in pixelArtEvaluation.layers[0].lines
        offsetPerceivedLineMarkup = Markup.PixelArt.perceivedLine line
        markup.push offsetPerceivedLineMarkup...

        for element in offsetPerceivedLineMarkup
          element.line.width = 2
          
          for point in element.line.points
            point.x += 12
            
            if point.bezierControlPoints
              for bezierControlPoint in point.bezierControlPoints
                bezierControlPoint.x += 12
        
      markup
    
    displaySide: ->
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom

  class @DrawFirstLine extends @StepInstruction
    @id: -> "#{StraightParts.id()}.DrawFirstLine"
    @stepNumber: -> 1
    
    @message: -> """
      Draw the curve by closely following the intended line and open the Smooth curves breakdown when you're done.
    """
    
    @initialize()

  class @AnalyzeFirstLine extends @StepInstruction
    @id: -> "#{StraightParts.id()}.AnalyzeFirstLine"
    @stepNumber: -> 2
    
    @message: -> """
      Straight parts are another criterion to consider when drawing smooth curves.

      Close the evaluation paper to see why.
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      @translateAndScaleTo 20, 14, 4
  
  class @FixFirstLine extends @StepInstruction
    @id: -> "#{StraightParts.id()}.FixFirstLine"
    @stepNumber: -> 3
    
    @message: -> """
      The intended line doesn't have any straight parts and always curves.
      However, the central segment in the pixel art version appears as a flat section due to its length.
      We can push pixels outwards to fix this.
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      @translateAndScaleTo 20, 20, 5
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      markup.push @movePixelMarkup(18, y, -1, 0)... for y in [10..17]

      textBase = Markup.textBase()
      palette = LOI.palette()
      
      pixelColor = palette.color Atari2600.hues.gray, 0
      pixelStyle = "##{pixelColor.getHexString()}"
      
      intendedLineColor = palette.color Atari2600.hues.gray, 3
      intendedLineStyle = "##{intendedLineColor.getHexString()}"
      
      # Add titles.
      markup.push
        text: _.extend {}, textBase,
          value: "INTENDED"
          position:
            x: 8, y: 1, origin: TextOriginPosition.BottomCenter
          style: intendedLineStyle
      ,
        text: _.extend {}, textBase,
          value: "ACTUAL"
          position:
            x: 20, y: 1, origin: TextOriginPosition.BottomCenter
          style: pixelStyle
      ,
        text: _.extend {}, textBase,
          value: "PERCEIVED"
          position:
            x: 32, y: 1, origin: TextOriginPosition.BottomCenter
          
      # Add intended lines.
      intendedLine =
        line:
          points: [
            x: 11, y: 3
          ,
            x: 6, y: 14, bezierControlPoints: [
              x: 8, y: 4
            ,
              x: 6, y: 6
            ]
          ,
            x: 11, y: 25, bezierControlPoints: [
              x: 6, y: 22
            ,
              x: 8, y: 24
            ]
          ]
        
      thickIntendedLine = _.cloneDeep intendedLine
      
      _.extend intendedLine.line,
        style: intendedLineStyle
        width: 0
      
      _.extend thickIntendedLine.line,
        style: pixelStyle
        absoluteWidth: 1
        cap: 'square'
      
      markup.push thickIntendedLine
      markup.push intendedLine
      
      # Add perceived lines.
      markup.push @perceivedLinesMarkup()...
        
      markup
      
  class @DrawSecondLine extends @StepInstruction
    @id: -> "#{StraightParts.id()}.DrawSecondLine"
    @stepNumber: -> 4
    
    @message: -> """
      Draw the left curve by closely following the intended line and open the Smooth curves breakdown.
    """
    
    @initialize()
    
  class @FixSecondLine extends @StepInstruction
    @id: -> "#{StraightParts.id()}.FixSecondLine"
    @stepNumber: -> 5
    
    @message: -> """
      This time we can smoothen the line by shortening the long segment.
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      @translateAndScaleTo 20, 14, 4
    
    markup: ->
      markup = []
      markup.push @movePixelMarkup(9, 6, 1, 0)...
      markup.push @movePixelMarkup(8, 8, 1, 0)...
      markup.push @movePixelMarkup(8, 9, 1, 0)...
      markup.push @movePixelMarkup(8, 18, -1, 0)...
      markup.push @movePixelMarkup(8, 19, -1, 0)...
      markup.push @movePixelMarkup(7, 21, -1, 0)...
      markup
      
  class @DrawThirdLine extends @StepInstruction
    @id: -> "#{StraightParts.id()}.DrawThirdLine"
    @stepNumber: -> 6
    
    @message: -> """
      Draw the final curves and open the Smooth curves breakdown.
    """
    
    @initialize()
    
  class @AnalyzeThirdLine extends @StepInstruction
    @id: -> "#{StraightParts.id()}.AnalyzeThirdLine"
    @stepNumber: -> 7
    
    @message: -> """
      Lines can also end with too long or too many repeating segments.
      It's rarely a problem, but it can be addressed similarly.
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      @translateAndScaleTo 20, 14, 4
    
  class @FixThirdLine extends @StepInstruction
    @id: -> "#{StraightParts.id()}.FixThirdLine"
    @stepNumber: -> 8
    
    @activeDisplayState: ->
      # We only have markup without a message.
      InstructionsSystem.DisplayState.Hidden
    
    @initialize()
    
    markup: ->
      markup = []
      markup.push @movePixelMarkup(31, 6, 1, 0)...
      markup.push @movePixelMarkup(32, 8, 1, 0)...
      markup.push @movePixelMarkup(28, 18, 1, 0)...
      markup.push @movePixelMarkup(28, 19, 1, 0)...
      markup.push @movePixelMarkup(29, 21, 1, 0)...
      markup
      
  class @Complete extends PAA.Tutorials.Drawing.Instructions.CompleteInstruction
    @id: -> "#{StraightParts.id()}.Complete"
    @assetClass: -> StraightParts
    
    @message: -> """
      These lines now flow smoothly.
      However, the straight parts criterion should be ignored when the intended lines indeed include straight parts.
      It's all about capturing the original intent.
    """
    
    @initialize()
    
    displaySide: ->
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
