LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.Circles extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.Circles"

  @displayName: -> "Circles"
  
  @description: -> """
    It's not surprising that the most rounded shape presents a decent challenge in pixel art.
  """
  
  @fixedDimensions: -> width: 205, height: 98
  @minClipboardScale: -> 1
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/curves/circles-#{step}.png" for step in [1..11]
  
  @markup: -> true
  
  @initialize()
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
    @sizeNumberXCoordinates = [4.5, 10, 16.5, 24, 32.5, 42, 52.5, 64, 76.5, 90, 104.5, 120, 136.5, 154, 172.5, 192]

    @maxSizeNumber: -> throw new AE.NotImplementedException "Step needs to specify up to which number to draw the sizes on top."

    markup: ->
      markup = []
      
      textBase = _.extend {}, Markup.textBase(),
        size: 8
        lineHeight: 10
      
      for number in [1..@constructor.maxSizeNumber()]
        markup.push
          text: _.extend {}, textBase,
            position:
              x: @constructor.sizeNumberXCoordinates[number - 1], y: -1, origin: Markup.TextOriginPosition.BottomCenter
            value: "#{number}"
  
      markup
      
    _addCircle: (markup, x, y, radius) ->
      markup.push
        line: _.extend {}, Markup.PixelArt.intendedLineBase(),
          arc: {x, y, radius}
  
  class @Size1 extends @StepInstruction
    @id: -> "#{Asset.id()}.Size1"
    @stepNumber: -> 1
    @maxSizeNumber: -> 1
    
    @message: -> """
      The smallest circle we can draw is simply a pixel.
    """

    @initialize()
  
    markup: ->
      markup = super arguments...
      
      markupStyle = Markup.defaultStyle()
      
      arrowBase =
        arrow:
          end: true
        style: markupStyle
      
      textBase = Markup.textBase()
      
      markup.push
        line: _.extend {}, arrowBase,
          points: [
            x: 8.5, y: 7
          ,
            x: 5.5, y: 5.5, bezierControlPoints: [
              x: 7, y: 7
            ,
              x: 5.75, y: 5.75
            ]
          ]
        text: _.extend {}, textBase,
          position:
            x: 9.5, y: 7, origin: Markup.TextOriginPosition.MiddleLeft
          value: "start\nhere"
          
      markup
      
  class @Size2 extends @StepInstruction
    @id: -> "#{Asset.id()}.Size2"
    @stepNumber: -> 2
    @maxSizeNumber: -> 2
    
    @message: -> """
      Just like the 1 px circle, the 2 px one could just as easily be a square.
      The viewer can still see a circle if it appears in the right context (for example, representing the wheels of a car).
    """
    
    @initialize()
  
  class @Size3 extends @StepInstruction
    @id: -> "#{Asset.id()}.Size3"
    @assetClass: -> Asset
    @stepNumber: -> 3
    @maxSizeNumber: -> 3
    
    @message: -> """
      A 3 px circle appears even more square.
    """
    
    @initialize()
  
  class @Size3Alternative extends @StepInstruction
    @id: -> "#{Asset.id()}.Size3Alternative"
    @assetClass: -> Asset
    @stepNumber: -> 4
    @maxSizeNumber: -> 3
    
    @message: -> """
      We now have enough space that we can remove the outer corners.
    """
    
    @initialize()

    markup: ->
      markup = super arguments...
      
      @_addCircle markup, 4.5, 4.5, 0.25
      @_addCircle markup, 10, 5, 0.5
      @_addCircle markup, 16.5, 5.5, 1
      
      markup
      
  class @Sizes4To6 extends @StepInstruction
    @id: -> "#{Asset.id()}.Sizes4To6"
    @assetClass: -> Asset
    @stepNumber: -> 5
    @maxSizeNumber: -> 6
    
    @message: -> """
      As we use this shape to draw bigger circles, it slowly starts resembling a square with rounded corners.
    """
    
    @initialize()
  class @Size6Alternative extends @StepInstruction
    @id: -> "#{Asset.id()}.Size6Alternative"
    @assetClass: -> Asset
    @stepNumber: -> 6
    @maxSizeNumber: -> 6
    
    @message: -> """
      With this much space, we can introduce a pixel that separates the longer segments.
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      @_addCircle markup, 16.5, 10.5, 1
      @_addCircle markup, 24, 11, 1.5
      @_addCircle markup, 32.5, 11.5, 2
      @_addCircle markup, 42, 12, 2.5
      
      markup
      
  class @Sizes7To10 extends @StepInstruction
    @id: -> "#{Asset.id()}.Sizes7To10"
    @assetClass: -> Asset
    @stepNumber: -> 7
    @maxSizeNumber: -> 10
    
    @message: -> """
      The circle again starts looking like a square with rounded corners as we increase the size even further.
    """
    
    @initialize()
    
  class @Sizes9To11 extends @StepInstruction
    @id: -> "#{Asset.id()}.Sizes9To11"
    @assetClass: -> Asset
    @stepNumber: -> 8
    @maxSizeNumber: -> 11
    
    @message: -> """
      We can introduce another pixel to connect the outside segments, but this eventually looks more like an octagon due to the 2 pixels creating a 45° diagonal.
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      @_addCircle markup, 42, 20, 2.5
      @_addCircle markup, 52.5, 20.5, 3
      @_addCircle markup, 64, 21, 3.5
      @_addCircle markup, 76.5, 21.5, 4
      @_addCircle markup, 90, 22, 4.5
      
      markup
  
  class @Sizes10To14 extends @StepInstruction
    @id: -> "#{Asset.id()}.Sizes10To14"
    @assetClass: -> Asset
    @stepNumber: -> 9
    @maxSizeNumber: -> 14
    
    @message: -> """
      To help break the diagonal, we can extend the pixels to length 2.
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      @_addCircle markup, 76.5, 33.5, 4
      @_addCircle markup, 90, 34, 4.5
      @_addCircle markup, 104.5, 34.5, 5
      @_addCircle markup, 120, 35, 5.5
      
      markup
      
  class @Sizes13To16 extends @StepInstruction
    @id: -> "#{Asset.id()}.Sizes13To16"
    @assetClass: -> Asset
    @stepNumber: -> 10
    @maxSizeNumber: -> 16
    
    @message: -> """
      With enough space, we can now introduce a pixel in between the angled segments.
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      @_addCircle markup, 90, 48, 4.5
      @_addCircle markup, 104.5, 48.5, 5
      @_addCircle markup, 120, 49, 5.5
      @_addCircle markup, 136.5, 49.5, 6
      @_addCircle markup, 154, 50, 6.5
      
      markup

  class @Size16Alternative extends @StepInstruction
    @id: -> "#{Asset.id()}.Size16Alternative"
    @assetClass: -> Asset
    @stepNumber: -> 11
    @maxSizeNumber: -> 16
    
    @message: -> """
      Finally, the 16 px circle can have two intermediate pixels at the diagonals.
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      @_addCircle markup, 120, 65, 5.5
      @_addCircle markup, 136.5, 65.5, 6
      @_addCircle markup, 154, 66, 6.5
      @_addCircle markup, 172.5, 66.5, 7
      @_addCircle markup, 192, 67, 7.5
      
      markup

  class @Complete extends @StepInstruction
    @id: -> "#{Asset.id()}.Complete"
    @maxSizeNumber: -> 16
    
    @message: -> """
      Bigger circles are easier to draw with the ellipse tool, but for smaller sizes, manual drawing often gives more aesthetic results than the shapes produced with algorithms.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
      
    @initialize()
