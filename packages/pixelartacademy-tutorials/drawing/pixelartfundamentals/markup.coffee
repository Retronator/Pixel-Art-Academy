AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Atari2600 = LOI.Assets.Palette.Atari2600
TextAlign = PAA.Practice.Tutorials.Drawing.MarkupEngineComponent.TextAlign
TextOriginPosition = PAA.Practice.Tutorials.Drawing.MarkupEngineComponent.TextOriginPosition

class PAA.Tutorials.Drawing.PixelArtFundamentals.Markup
  @defaultStyle: ->
    palette = LOI.palette()
    markupColor = palette.color Atari2600.hues.azure, 4
    
    "##{markupColor.getHexString()}"
  
  @betterStyle: ->
    palette = LOI.palette()
    lineColor = palette.color Atari2600.hues.green, 4
    
    "##{lineColor.getHexString()}"
  
  @mediocreStyle: ->
    palette = LOI.palette()
    lineColor = palette.color Atari2600.hues.yellow, 4
    
    "##{lineColor.getHexString()}"
  
  @worseStyle: ->
    palette = LOI.palette()
    lineColor = palette.color Atari2600.hues.peach, 5
    
    "##{lineColor.getHexString()}"
    
  @jaggyStyle: ->
    palette = LOI.palette()
    jaggyColor = palette.color Atari2600.hues.red, 3
    
    "##{jaggyColor.getHexString()}"
    
  @textBase: ->
    size: 6
    lineHeight: 7
    font: 'Small Print Retronator'
    style: @defaultStyle()
    align: TextAlign.Center
  
  @intendedLineBase: ->
    palette = LOI.palette()
    lineColor = palette.color Atari2600.hues.azure, 5
    
    style: "##{lineColor.getHexString()}"
    
  @diagonalRatioText: (straightLine, grading) ->
    grading ?= straightLine.grade()
    
    startPoint = _.first straightLine.points
    endPoint = _.last straightLine.points
    rightPoint = if endPoint.x > startPoint.x then endPoint else startPoint
    
    text: _.extend @textBase(),
      position:
        x: rightPoint.x + 1.75, y: rightPoint.y - 0.75, origin: TextOriginPosition.BottomLeft
      value: "#{grading.diagonalRatio.numerator}:#{grading.diagonalRatio.denominator}"
      
  @intendedLine: (straightLine) ->
    line: _.extend Markup.intendedLineBase(),
      points: [
        x: straightLine.displayLine2.start.x + 0.5, y: straightLine.displayLine2.start.y + 0.5
      ,
        x: straightLine.displayLine2.end.x + 0.5, y: straightLine.displayLine2.end.y + 0.5
      ]
