LOI = LandsOfIllusions
PAA = PixelArtAcademy

Atari2600 = LOI.Assets.Palette.Atari2600

_offsetDirection = new THREE.Vector2

class PAA.Practice.Helpers.Drawing.Markup
  @TextOriginPosition =
    TopLeft: 'TopLeft'
    TopCenter: 'TopCenter'
    TopRight: 'TopRight'
    MiddleLeft: 'MiddleLeft'
    MiddleCenter: 'MiddleCenter'
    MiddleRight: 'MiddleRight'
    BottomLeft: 'BottomLeft'
    BottomCenter: 'BottomCenter'
    BottomRight: 'BottomRight'
  
  @TextAlign =
    Left: 'Left'
    Center: 'Center'
    Right: 'Right'

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
    
  @errorStyle: ->
    palette = LOI.palette()
    errorColor = palette.color Atari2600.hues.red, 3
    
    "##{errorColor.getHexString()}"
    
  @backgroundStyle: ->
    palette = LOI.palette()
    backgroundColor = palette.color Atari2600.hues.gray, 7
    
    "##{backgroundColor.getHexString()}"
    
  @textBase: ->
    size: 5
    lineHeight: 7
    font: 'Small Print Retronator'
    style: @defaultStyle()
    outline:
      style: @backgroundStyle()
    align: @TextAlign.Center
  
  @percentage: (value) ->
    return "N/A" unless value?
    
    "#{Math.floor value * 100}%"
  
  @offsetPoints: (points, amount) ->
    offsetPoints = _.cloneDeep points
    
    for point, pointIndex in points
      previousPointForDirection = points[pointIndex - 1] or point
      nextPointForDirection = points[pointIndex + 1] or point
      
      _offsetDirection.x = previousPointForDirection.y - nextPointForDirection.y
      _offsetDirection.y = nextPointForDirection.x - previousPointForDirection.x
      _offsetDirection.normalize().multiplyScalar amount
      
      offsetPoint = offsetPoints[pointIndex]
      offsetPoint.x += _offsetDirection.x
      offsetPoint.y += _offsetDirection.y
      
      if offsetPoint.bezierControlPoints
        offsetPoint.bezierControlPoints[1].x += _offsetDirection.x
        offsetPoint.bezierControlPoints[1].y += _offsetDirection.y
      
      nextOffsetPoint = offsetPoints[pointIndex + 1]
      if nextOffsetPoint?.bezierControlPoints
        nextOffsetPoint.bezierControlPoints[0].x += _offsetDirection.x
        nextOffsetPoint.bezierControlPoints[0].y += _offsetDirection.y
    
    offsetPoints
