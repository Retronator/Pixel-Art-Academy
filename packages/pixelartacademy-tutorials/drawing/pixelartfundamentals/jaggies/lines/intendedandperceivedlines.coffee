LOI = LandsOfIllusions
PAA = PixelArtAcademy

TextOriginPosition = PAA.Practice.Helpers.Drawing.Markup.TextOriginPosition
Atari2600 = LOI.Assets.Palette.Atari2600
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.IntendedAndPerceivedLines extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.IntendedAndPerceivedLines"
  
  @displayName: -> "Intended and perceived lines"
  
  @description: -> """
    What the artist intends to draw and what the viewer perceives does not always match with what is actually on the canvas.
  """
  
  @fixedDimensions: -> width: 90, height: 50
  
  @svgUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/lines/Intendedandperceivedlines.svg"
  @breakPathsIntoSteps: -> true
  
  @markup: -> true
  @pixelArtEvaluation: -> partialUpdates: true
  
  @initialize()
  
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    svgPaths = stepResources.svgPaths.svgPaths()
  
    for svgPath, index in svgPaths
      new @constructor.PathStep @, stepArea,
        svgPaths: [svgPath]
        # Don't require very precise lines.
        tolerance: 1

  Asset = @
  
  class @Horizontal extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Horizontal"
    @assetClass: -> Asset
    @stepNumber: -> 1
    
    @message: -> """
      Pixel art is drawn on a raster grid. When we draw lines that align with the grid, the result perfectly matches the intended shapes.
    """
    
    @initialize()
  
  class @Diagonal extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Diagonal"
    @assetClass: -> Asset
    @stepNumber: -> 2
    
    @message: -> """
      When lines don't align with the grid, the resulting shape doesn't match exactly.
      Instead of a single line at an angle, we end up with multiple rectangles aligned to the grid.
    """
    
    @initialize()
  
  class @Curve extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Curve"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      However, because of how the pixels are connected, the viewer still perceives the result as a diagonal or a curve.
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      
      for line in pixelArtEvaluation.layers[0].lines
        markup.push Markup.PixelArt.perceivedLine(line)...
        
      markup
    
  class @Complete extends PAA.Tutorials.Drawing.Instructions.CompletedInstruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @activeDisplayState: ->
      # We only have markup without a message.
      PAA.PixelPad.Systems.Instructions.DisplayState.Hidden
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []

      textBase = Markup.textBase()
      palette = LOI.palette()
      
      pixelColor = palette.color Atari2600.hues.gray, 0
      pixelStyle = "##{pixelColor.getHexString()}"
      
      intendedLineColor = palette.color Atari2600.hues.gray, 3
      intendedLineStyle = "##{intendedLineColor.getHexString()}"
      
      # Add titles.
      titleBase = _.extend {}, textBase,
        size: 8
        lineHeight: 10
      
      markup.push
        text: _.extend {}, titleBase,
          value: "INTENDED\nLINES"
          position:
            x: 17, y: 6, origin: TextOriginPosition.MiddleCenter
          style: intendedLineStyle
      ,
        text: _.extend {}, textBase,
          value: "What the artist wants\nto communicate"
          position:
            x: 17, y: 44, origin: TextOriginPosition.MiddleCenter
          style: intendedLineStyle
      ,
        text: _.extend {}, titleBase,
          value: "ACTUAL\nLINES"
          position:
            x: 45, y: 6, origin: TextOriginPosition.MiddleCenter
          style: pixelStyle
      ,
        text: _.extend {}, textBase,
          value: "What is on the canvas"
          position:
            x: 45, y: 44, origin: TextOriginPosition.MiddleCenter
          style: pixelStyle
      ,
        text: _.extend {}, titleBase,
          value: "PERCEIVED\nLINES"
          position:
            x: 73, y: 6, origin: TextOriginPosition.MiddleCenter
      ,
        text: _.extend {}, textBase,
          value: "What the viewer\ninterprets"
          position:
            x: 73, y: 44, origin: TextOriginPosition.MiddleCenter
          
      # Add intended lines.
      intendedLineBase =
        style: intendedLineStyle
        width: 0
      
      intendedLines = [
        line: _.extend {}, intendedLineBase,
          points: [
            x: 6.5, y: 12.5
          ,
            x: 27.5, y: 12.5
          ]
      ,
        line: _.extend {}, intendedLineBase,
          points: [
            x: 6.5, y: 27.75
          ,
            x: 27.5, y: 17.25
          ]
      ,
        line: _.extend {}, intendedLineBase,
          points: [
            x: 6.5, y: 34.5
          ,
            x: 11.5, y: 32.5, bezierControlPoints: [
              x: 7.25, y: 33.5
            ,
              x: 10, y: 32.5
            ]
          ,
            x: 22.5, y: 37.5, bezierControlPoints: [
              x: 17, y: 32.5
            ,
              x: 17, y: 37.5
            ]
          ,
            x: 27.5, y: 35.5, bezierControlPoints: [
              x: 24, y: 37.5
            ,
              x: 26.75, y: 36.5
            ]
          ]
      ]
      
      thickIntendedLines = _.cloneDeep intendedLines
      
      for line in thickIntendedLines
        _.extend line.line,
          style: pixelStyle
          absoluteWidth: 1
          cap: 'square'
      
      markup.push thickIntendedLines...
      markup.push intendedLines...
      
      # Add perceived lines.
      for line in pixelArtEvaluation.layers[0].lines
        offsetPerceivedLineMarkup = Markup.PixelArt.perceivedLine line
        markup.push offsetPerceivedLineMarkup...

        for element in offsetPerceivedLineMarkup
          element.line.width = 2
          
          for point in element.line.points
            point.x += 28
            
            if point.bezierControlPoints
              for bezierControlPoint in point.bezierControlPoints
                bezierControlPoint.x += 28
        
      markup
