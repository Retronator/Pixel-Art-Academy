LOI = LandsOfIllusions
PAA = PixelArtAcademy

TextOriginPosition = PAA.Practice.Helpers.Drawing.Markup.TextOriginPosition
Atari2600 = LOI.Assets.Palette.Atari2600
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.Jaggies extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.Jaggies"
  
  @displayName: -> "Jaggies"
  
  @description: -> """
    Learn about the main stylistic characteristic of pixel art.
  """
  
  @fixedDimensions: -> width: 41, height: 21
  
  @svgUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/lines/jaggies.svg"
  @breakPathsIntoSteps: -> true
  
  @markup: -> true
  @pixelArtEvaluation: -> true
  
  @initialize()
  
  Asset = @
  
  class @Aligned extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Aligned"
    @assetClass: -> Asset
    @stepNumber: -> 1
    
    @message: -> """
      Many things in your drawings will align with the grid. Pixels can perfectly match such shapes.
    """
    
    @initialize()
  
  class @NonAligned extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.NonAligned"
    @assetClass: -> Asset
    @stepNumber: -> 2
    
    @message: -> """
      With diagonals and curves, what should be straight and smooth appears jagged—spiky and sharp.
      These stair-like deformations (unintended jagged edges) are called 'jaggies' and contribute to the blocky appearance of pixel art.
    """
    
    @initialize()
  
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
      
      # Add jaggies.
      palette = LOI.palette()
      lineColor = palette.color Atari2600.hues.green, 3
      jaggyBase = style: "##{lineColor.getHexString()}"
      
      return unless trashCanLine = pixelArtEvaluation.getLinesAt(6, 12)?[0]
      return unless lampLine = pixelArtEvaluation.getLinesAt(13, 6)?[0]
      return unless handrailLine = pixelArtEvaluation.getLinesAt(17, 12)?[0]
      
      for line in [trashCanLine, lampLine, handrailLine]
        for jaggy in line.getJaggies()
          markup.push
            pixel: _.extend {}, jaggyBase,
              x: jaggy.x
              y: jaggy.y
      
      # Add jaggy arrows.
      markupStyle = Markup.defaultStyle()
      
      arrowBase =
        arrow:
          end: true
        style: markupStyle
        
      textBase = Markup.textBase()
      
      markup.push
        line: _.extend {}, arrowBase,
          points: [
            x: 28.5, y: 16.5
          ,
            x: 25.5, y: 14.5, bezierControlPoints: [
              x: 26.5, y: 16.5
            ,
              x: 26, y: 15
            ]
          ]
        text: _.extend {}, textBase,
          position:
            x: 28.5, y: 16.5, origin: TextOriginPosition.TopLeft
          value: "not jaggies\n(actual stairs)"

      markup.push
        line: _.extend {}, arrowBase,
          points: [
            x: 20.5, y: 6.5
          ,
            x: 20.5, y: 9.5, bezierControlPoints: [
              x: 19, y: 8
            ,
              x: 20, y: 9
            ]
          ]
        text: _.extend {}, textBase,
          position:
            x: 21, y: 6.5, origin: TextOriginPosition.BottomLeft
          value: "jaggies\n(diagonal)"
      
      markup.push
        line: _.extend {}, arrowBase,
          points: [
            x: 11, y: 4
          ,
            x: 12.5, y: 5, bezierControlPoints: [
              x: 11, y: 5
            ,
              x: 12, y: 5
            ]
          ]
        text: _.extend {}, textBase,
          position:
            x: 11, y: 3.5, origin: TextOriginPosition.BottomCenter
          value: "jaggies\n(curve)"
      
      markup.push
        line: _.extend {}, arrowBase,
          points: [
            x: 4.5, y: 10
          ,
            x: 5.5, y: 11.5, bezierControlPoints: [
              x: 4.5, y: 11
            ,
              x: 5.25, y: 11.25
            ]
          ]
        text: _.extend {}, textBase,
          position:
            x: 4.5, y: 9.5, origin: TextOriginPosition.BottomCenter
          value: "not a jaggy\n(sharp corner)"
      
      # Add perceived lines.
      perceivedLineBase = Markup.PixelArt.perceivedLineBase()
      
      markup.push
        line: _.extend {}, perceivedLineBase,
          points: [
            x: 18.5, y: 16.5
          ,
            x: 18.5, y: 15.5
          ,
            x: 20.5, y: 15.5
          ,
            x: 20.5, y: 14.5
          ,
            x: 22.5, y: 14.5
          ,
            x: 22.5, y: 13.5
          ,
            x: 24.5, y: 13.5
          ,
            x: 24.5, y: 12.5
          ,
            x: 26.5, y: 12.5
          ]
      
      markup.push
        line: _.extend {}, perceivedLineBase,
          points: [
            x: 16.5, y: 14.5
          ,
            x: 17.5, y: 12.75, bezierControlPoints: [
              x: 16.5, y: 13.5
            ,
              x: 17, y: 13
            ]
          ,
            x: 23.25, y: 9.875
          ,
            x: 25.125, y: 10.125, bezierControlPoints: [
              x: 23.75, y: 9.625
            ,
              x: 24.625, y: 9.625
            ]
          ,
            x: 25.5, y: 11.125, bezierControlPoints: [
              x: 25.325, y: 10.325
            ,
              x: 25.5, y: 10.625
            ]
          ]
      
      markup.push
        line: _.extend {}, perceivedLineBase,
          points: [
            x: 13.5, y: 6.25
          ,
            x: 15.25, y: 4.5, bezierControlPoints: [
              x: 13.5, y: 5.25
            ,
              x: 14.26, y: 4.5
            ]
          ]
      
      markup.push
        line: _.extend {}, perceivedLineBase,
          points: [
            x: 7.5, y: 16
          ,
            x: 6.625, y: 12.5
          ,
            x: 10.375, y: 12.5
          ,
            x: 9.5, y: 16
          ]
      
      markup
