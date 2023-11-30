LOI = LandsOfIllusions
PAA = PixelArtAcademy

TextOriginPosition = PAA.Practice.Tutorials.Drawing.MarkupEngineComponent.TextOriginPosition
TextAlign = PAA.Practice.Tutorials.Drawing.MarkupEngineComponent.TextAlign
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Jaggies extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @displayName: -> "Jaggies"
  
  @description: -> """
    Learn about the main stylistic characteristic of pixel art.
  """
  
  @fixedDimensions: -> width: 45, height: 25
  
  @markup: -> true
  @pixelArtGrading: -> true
  
  @initialize()
  
  Asset = @
  
  class @InstructionStep extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
    @assetClass: -> Asset
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show with the correct step.
      return unless asset.currentActivePathIndex() is @stepNumber() - 1
      
      # Show until the asset is completed.
      not asset.completed()
    
    @resetDelayOnOperationExecuted: -> true
    
  class @Aligned extends @InstructionStep
    @id: -> "#{Asset.id()}.Aligned"
    @stepNumber: -> 1
    
    @message: -> """
      Pixel art is drawn on a raster grid. When we draw lines and edges that align with the grid, the result perfectly matches the intended shapes.
    """
    
    @initialize()
  
  class @NonAligned extends @InstructionStep
    @id: -> "#{Asset.id()}.NonAligned"
    @stepNumber: -> 2
    
    @message: -> """
      When lines don't align with the grid, such as with diagonals and curves, they become jagged—spiky and sharp.
      These stair-like deformations are called 'jaggies' and contribute to the blocky appearance of pixel art.
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
      palette = LOI.palette()
      
      return unless asset = @getActiveAsset()
      return unless pixelArtGrading = asset.pixelArtGrading()
      
      markup = []
      
      # Add jaggies.
      jaggyColor = palette.color Atari2600.hues.red, 3
      jaggyStyle =
        style: "##{jaggyColor.getHexString()}"
        
      return unless trashCanLine = pixelArtGrading.getLinesAt(8, 14)?[0]
      return unless lampLine = pixelArtGrading.getLinesAt(15, 8)?[0]
      return unless handrailLine = pixelArtGrading.getLinesAt(19, 14)?[0]
      
      for line in [trashCanLine, lampLine, handrailLine]
        for jaggy in line.getJaggies()
          markup.push
            pixel: _.extend {}, jaggyStyle,
              x: jaggy.x
              y: jaggy.y
      
      # Add jaggy arrows.
      markupColor = palette.color Atari2600.hues.azure, 4
      markupStyle = "##{markupColor.getHexString()}"
      
      arrowStyle =
        arrow:
          end: true
        style: markupStyle
        
      textStyle =
        size: 6
        lineHeight: 7
        font: 'Small Print Retronator'
        style: markupStyle
        align: TextAlign.Center
      
      markup.push
        line: _.extend {}, arrowStyle,
          points: [
            x: 26.5, y: 20.5
          ,
            x: 23.5, y: 18.5, bezierControlPoints: [
              x: 24.5, y: 20.5
            ,
              x: 24, y: 19
            ]
          ]
        text: _.extend {}, textStyle,
          position:
            x: 26.5, y: 20.5, origin: TextOriginPosition.TopLeft
          value: "not a jaggy\n(actual stairs)"

      markup.push
        line: _.extend {}, arrowStyle,
          points: [
            x: 20.5, y: 9.5
          ,
            x: 20.5, y: 12.5, bezierControlPoints: [
              x: 19, y: 11
            ,
              x: 20, y: 12
            ]
          ]
        text: _.extend {}, textStyle,
          position:
            x: 21, y: 9.5, origin: TextOriginPosition.BottomLeft
          value: "jaggy\n(diagonal)"
      
      markup.push
        line: _.extend {}, arrowStyle,
          points: [
            x: 13, y: 6
          ,
            x: 14.5, y: 7, bezierControlPoints: [
              x: 13, y: 7
            ,
              x: 14, y: 7
            ]
          ]
        text: _.extend {}, textStyle,
          position:
            x: 13, y: 5.5, origin: TextOriginPosition.BottomCenter
          value: "jaggy\n(curve)"
      
      markup.push
        line: _.extend {}, arrowStyle,
          points: [
            x: 6.5, y: 12
          ,
            x: 7.5, y: 13.5, bezierControlPoints: [
              x: 6.5, y: 13
            ,
              x: 7.25, y: 13.25
            ]
          ]
        text: _.extend {}, textStyle,
          position:
            x: 6.5, y: 11.5, origin: TextOriginPosition.BottomCenter
          value: "not a jaggy\n(sharp corner)"
      
      # Add intended lines.
      intendedLineColor = palette.color Atari2600.hues.azure, 5
      intendedLineStyle =
        style: "##{intendedLineColor.getHexString()}"
      
      markup.push
        line: _.extend {}, intendedLineStyle,
          points: [
            x: 20.5, y: 18.5
          ,
            x: 20.5, y: 17.5
          ,
            x: 22.5, y: 17.5
          ,
            x: 22.5, y: 16.5
          ,
            x: 24.5, y: 16.5
          ,
            x: 24.5, y: 15.5
          ,
            x: 26.5, y: 15.5
          ]
      
      markup.push
        line: _.extend {}, intendedLineStyle,
          points: [
            x: 18.5, y: 16.5
          ,
            x: 19.5, y: 14.75, bezierControlPoints: [
              x: 18.5, y: 15.5
            ,
              x: 19, y: 15
            ]
          ,
            x: 25.25, y: 11.875
          ,
            x: 27.125, y: 12.125, bezierControlPoints: [
              x: 25.75, y: 11.625
            ,
              x: 26.625, y: 11.625
            ]
          ,
            x: 27.5, y: 13.125, bezierControlPoints: [
              x: 27.325, y: 12.325
            ,
              x: 27.5, y: 12.625
            ]
          ]
      
      markup.push
        line: _.extend {}, intendedLineStyle,
          points: [
            x: 15.5, y: 8.25
          ,
            x: 17.25, y: 6.5, bezierControlPoints: [
              x: 15.5, y: 7.25
            ,
              x: 16.26, y: 6.5
            ]
          ]
      
      markup.push
        line: _.extend {}, intendedLineStyle,
          points: [
            x: 9.5, y: 18
          ,
            x: 8.625, y: 14.5
          ,
            x: 12.375, y: 14.5
          ,
            x: 11.5, y: 18
          ]
      
      markup
