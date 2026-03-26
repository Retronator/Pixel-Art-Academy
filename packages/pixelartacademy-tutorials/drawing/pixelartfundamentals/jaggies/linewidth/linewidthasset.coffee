LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.LineWidth extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.LineWidth"

  @displayName: -> "Line width"
  
  @description: -> """
    The width (or weight) of the line can be altered by using doubles.
  """
  
  @fixedDimensions: -> width: 45, height: 45
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/linewidth-#{step}.png" for step in [1..5]
  
  @markup: -> true
  @pixelArtEvaluation: -> true
  
  @initialize()
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      
      # Add perceived lines for straight lines during the lesson.
      unless asset.completed()
        for line in pixelArtEvaluation.layers[0].lines
          continue unless line.parts.length is 1
          linePart = line.parts[0]
          continue unless linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
          
          markup.push Markup.PixelArt.perceivedStraightLine linePart
      
      # Add titles.
      textBase = Markup.textBase()
      
      if @constructor.stepNumber() >= 1
        markup.push
          text: _.extend {}, textBase,
            position:
              x: 0.5, y: 0.5, origin: Markup.TextOriginPosition.TopLeft
            value: "Thin (1-pixel) lines"
      
      if @constructor.stepNumber() >= 3
        markup.push
          text: _.extend {}, textBase,
            position:
              x: 44.5, y: 0.5, origin: Markup.TextOriginPosition.TopRight
            value: "Thick (1-pixel) lines"
            
      if @constructor.stepNumber() >= 4
        markup.push
          text: _.extend {}, textBase,
            position:
              x: 44.5, y: 44.5, origin: Markup.TextOriginPosition.BottomRight
            value: "Wide (2-pixel) lines"
            
      # Add widths.
      markupStyle = Markup.defaultStyle()
      
      arrowBase =
        arrow:
          end: true
        style: markupStyle
      
      textBase = Markup.textBase()
      
      width1X = 3.5
      width0XY = 11
      
      endOffset = 0.1
      endOffsetZeroWidth = 0.2
      startOffset = 1.2
      startOffsetVertical = 1.6
      
      if 1 <= @constructor.stepNumber() <= 2 and pixelArtEvaluation.getLinesBetween({x: 3, y: 22}, {x: 14, y: 22}).length
        markup.push
          line: _.extend {}, arrowBase,
            points: [
              x: width1X, y: 23 + startOffsetVertical
            ,
              x: width1X, y: 23 + endOffset
            ]
        ,
          line: _.extend {}, arrowBase,
            points: [
              x: width1X, y: 22 - startOffsetVertical
            ,
              x: width1X, y: 22 - endOffset
            ]
          text: _.extend {}, textBase,
            position:
              x: width1X, y: 22 - startOffsetVertical, origin: Markup.TextOriginPosition.BottomCenter
            value: "1"
      
      if @constructor.stepNumber() is 2 and pixelArtEvaluation.getLinesBetween({x: 8, y: 8}, {x: 17, y: 17}).length
        markup.push
          line: _.extend {}, arrowBase,
            points: [
              x: 8 - startOffset, y: 9 + startOffset
            ,
              x: 8 - endOffset, y: 9 + endOffset
            ]
        ,
          line: _.extend {}, arrowBase,
            points: [
              x: 9 + startOffset, y: 8 - startOffset
            ,
              x: 9 + endOffset, y: 8 - endOffset
            ]
          text: _.extend {}, textBase,
            position:
              x: 9 + startOffset, y: 8 - startOffset, origin: Markup.TextOriginPosition.BottomLeft
            value: "1.4"
        ,
          line: _.extend {}, arrowBase,
            points: [
              x: width0XY - startOffset, y: width0XY + startOffset
            ,
              x: width0XY - endOffsetZeroWidth, y: width0XY + endOffsetZeroWidth
            ]
        ,
          line: _.extend {}, arrowBase,
            points: [
              x: width0XY + startOffset, y: width0XY - startOffset
            ,
              x: width0XY + endOffsetZeroWidth, y: width0XY - endOffsetZeroWidth
            ]
          text: _.extend {}, textBase,
            position:
              x: width0XY + startOffset, y: width0XY - startOffset, origin: Markup.TextOriginPosition.BottomLeft
            value: "0"
            
      markup
      
  class @Width1 extends @StepInstruction
    @id: -> "#{Asset.id()}.Width1"
    @stepNumber: -> 1
    
    @message: -> """
      The typical line in pixel art is 1 pixel wide, but we can only perfectly achieve it with horizontals and verticals.
    """

    @initialize()

  class @Width1Thin extends @StepInstruction
    @id: -> "#{Asset.id()}.Width1Thin"
    @stepNumber: -> 2
    
    @message: -> """
      With diagonals, due to jaggies, the width along the line varies.
      The thin 1-pixel line alternates from 1.4 px at its widest down to 0 px in the corners of the jaggies.
    """
    
    @initialize()
    
  class @Width1Thick extends @StepInstruction
    @id: -> "#{Asset.id()}.Width1Thick"
    @stepNumber: -> 3
    
    @message: -> """
      If we want the line to be clearly connected and ensure it is at least 1 pixel wide, we need to add doubles to achieve a thick 1-pixel line.
    """
    
    @initialize()
    
  class @Width2 extends @StepInstruction
    @id: -> "#{Asset.id()}.Width2"
    @stepNumber: -> 4
    
    @message: -> """
      Although less common, given enough space, 2-pixel lines also make an appearance.
      Use the +/- keys or ctrl + mouse scroll to increase or decrease your brush size.
    """
    
    @initialize()
    
  class @Width2ThinThick extends @StepInstruction
    @id: -> "#{Asset.id()}.Width2ThinThick"
    @stepNumber: -> 5
    
    @message: -> """
      Here too we can choose variations of thin or thick 2-pixel diagonals.
    """
    
    @initialize()
  
  class @Complete extends @StepInstruction
    @id: -> "#{Asset.id()}.Complete"
    @stepNumber: -> 6
    
    @activeDisplayState: ->
      # We only have markup without a message.
      PAA.PixelPad.Systems.Instructions.DisplayState.Hidden
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
