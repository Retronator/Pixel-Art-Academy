LOI = LandsOfIllusions
PAA = PixelArtAcademy

Atari2600 = LOI.Assets.Palette.Atari2600

Markup = PAA.Practice.Helpers.Drawing.Markup

class Markup.PixelArt
  @intendedLineBase: ->
    palette = LOI.palette()
    lineColor = palette.color Atari2600.hues.azure, 5
    
    style: "##{lineColor.getHexString()}"
  
  @diagonalRatioText: (straightLine, grading) ->
    grading ?= straightLine.grade()
    
    startPoint = _.first straightLine.points
    endPoint = _.last straightLine.points
    rightPoint = if endPoint.x > startPoint.x then endPoint else startPoint
    
    text: _.extend Markup.textBase(),
      position:
        x: rightPoint.x + 1.75, y: rightPoint.y - 0.75, origin: Markup.TextOriginPosition.BottomLeft
      value: "#{grading.diagonalRatio.numerator}:#{grading.diagonalRatio.denominator}"
  
  @intendedLine: (straightLine) ->
    line: _.extend @intendedLineBase(),
      points: [
        x: straightLine.displayLine2.start.x + 0.5, y: straightLine.displayLine2.start.y + 0.5
      ,
        x: straightLine.displayLine2.end.x + 0.5, y: straightLine.displayLine2.end.y + 0.5
      ]
