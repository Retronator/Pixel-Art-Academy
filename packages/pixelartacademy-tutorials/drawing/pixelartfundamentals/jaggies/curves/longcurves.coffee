LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.LongCurves extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.LongCurves"

  @displayName: -> "Long curves"
  
  @description: -> """
    Large circles and other long curves that slowly change direction run into the same problems as uneven diagonals.
  """
  
  @fixedDimensions: -> width: 67, height: 35
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/curves/longcurves-#{step}.png" for step in [1..2]
  
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
      
      for line in pixelArtEvaluation.layers[0].lines
        # Write segment lengths next to lines.
        markup.push Markup.PixelArt.pointSegmentLengthTexts(line)...

      markup
  
  class @Uneven extends @StepInstruction
    @id: -> "#{Asset.id()}.Uneven"
    @stepNumber: -> 1
    
    @message: -> """
      When a circle becomes large enough, longer parts of its arc will lie between the 1:2 and 1:1 angles.
      If we try to follow the curve closely, we can't have only monotonically changing segment lengths.
    """

    @initialize()
    
    markup: ->
      markup = super arguments...
      
      markup.push
        line:
          style: "rgb(0 0 0 / 0.25)"
          width: 0
          arc:
            x: 32
            y: 32
            radius: 28.5
            startAngle: Math.PI
            endAngle: Math.PI * 1.5
            
      markup
  
  class @Even extends @StepInstruction
    @id: -> "#{Asset.id()}.Even"
    @stepNumber: -> 2
    
    @message: -> """
      Some artists live with this imperfection (as with uneven diagonals), while others construct curves only out of even diagonals, at the expense of the curve looking more 'angular'.
    """
    
    @initialize()
  
  class @Complete extends PAA.Tutorials.Drawing.Instructions.CompleteInstruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
      In practice, these choices are part of the art process and lead to different kinds of stylizations.
    """
    
    @initialize()
    
    @MarkupType:
      None: 'None'
      IntendedLine: 'IntendedLine'
      PerceivedLine: 'PerceivedLine'
      Curvature: 'Curvature'
      
    constructor: ->
      super arguments...
      
      @markupType = new ReactiveField @constructor.MarkupType.None
      
    onActivate: ->
      super arguments...
      
      @markupType @constructor.MarkupType.None
      
      @_changeMarkupTypeInterval = Meteor.setInterval =>
        markupTypes = _.keys @constructor.MarkupType
        currentMarkupTypeIndex = markupTypes.indexOf @markupType()
        
        @markupType markupTypes[(currentMarkupTypeIndex + 1) % 4]
      ,
        2000
      
    onDeactivate: ->
      super arguments...
      
      Meteor.clearInterval @_changeMarkupTypeInterval
    
    markup: ->
      markupType = @markupType()
      return if markupType is @constructor.MarkupType.None
      
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      
      switch markupType
        when @constructor.MarkupType.IntendedLine
          lineBase = Markup.PixelArt.perceivedLineBase()
          
          for x in [32, 64]
            markup.push
              line: _.extend {}, lineBase,
                arc:
                  x: x
                  y: 32
                  radius: 28.5
                  startAngle: Math.PI
                  endAngle: Math.PI * 1.5
            
        when @constructor.MarkupType.PerceivedLine
          for line in pixelArtEvaluation.layers[0].lines
            markup.push Markup.PixelArt.segmentedPerceivedLine line
            
        when @constructor.MarkupType.Curvature
          for line in pixelArtEvaluation.layers[0].lines
            for curve in line.curvatureCurveParts
              perceivedLineMarkup = Markup.PixelArt.perceivedCurve curve
              perceivedLineMarkup.line.arrow = start: true
              perceivedLineMarkup.line.points = Markup.offsetPoints perceivedLineMarkup.line.points, if curve.clockwise then -2 else 2
    
              markup.push perceivedLineMarkup
        
      markup
