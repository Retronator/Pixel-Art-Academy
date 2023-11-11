AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

deepCoreColor = "hsl(100deg 50% 50% / 50%)"
shallowCoreColor = "hsl(60deg 50% 50% / 40%)"
pointColor = "hsl(350deg 50% 50%)"
edgeColor = "hsl(200deg 50% 50% / 50%)"
diagonalColor = "hsl(60deg 50% 50% / 100%)"

_diagonalLine = new THREE.Line3

class PAG.EngineComponent
  constructor: (@options) ->
    @ready = new ComputedField =>
      return unless @options.pixelArtGrading()

      true

  drawToContext: (context, renderOptions = {}) ->
    return unless @ready()
    
    @_pixelSize = 1 / renderOptions.camera.effectiveScale()
    
    @_render context

  _render: (context) ->
    pixelArtGrading = @options.pixelArtGrading()
    
    # Draw deep core pixels.
    #context.beginPath()
    #@_addPixelToPath context, pixel for pixel in pixelArtGrading.pixels when pixel.isDeepCore
    #@_diagonalDash context, pixelArtGrading.bitmap.bounds, deepCoreColor
    
    # Draw shallow core pixels.
    #context.beginPath()
    #@_addPixelToPath context, pixel for pixel in pixelArtGrading.pixels when pixel.isShallowCore
    #@_diagonalDash context, pixelArtGrading.bitmap.bounds, shallowCoreColor
    
    # Draw point network.
    #for point in pixelArtGrading.points
    #  @_drawEdge context, point, neighbor for neighbor in point.neighbors
    
    # Draw points.
    #@_drawPoint context, point for point in pixelArtGrading.points
    
    # Draw lines.
    #@_drawLine context, line for line in pixelArtGrading.lines
    
    # Draw diagonals.
    for line in pixelArtGrading.lines
      for diagonal in line.diagonals
        @_drawDiagonal context, diagonal.startPoint, diagonal.endPoint

  _addPixelToPath: (context, pixel) ->
    context.rect pixel.x, pixel.y, 1, 1

  _diagonalDash: (context, bounds, color) ->
    context.save()
    context.clip()
    context.strokeStyle = color
    context.lineWidth = @_pixelSize
    context.beginPath()
    
    for x in [-bounds.height...bounds.width] by 5 * @_pixelSize
      context.moveTo x, 0
      context.lineTo x + bounds.height, bounds.height
      
    context.stroke()
    context.restore()
  
  _drawEdge: (context, pointA, pointB) ->
    context.strokeStyle = edgeColor
    context.lineWidth = @_pixelSize * 2
    context.beginPath()
    
    context.moveTo pointA.x + 0.5, pointA.y + 0.5
    context.lineTo pointB.x + 0.5, pointB.y + 0.5
    
    context.stroke()
    
  _drawPoint: (context, point) ->
    context.beginPath()
    context.arc point.x + 0.5, point.y + 0.5, @_pixelSize * 3, 0, 2 * Math.PI
    context.fillStyle = pointColor
    context.fill()

  _drawLine: (context, line) ->
    hueDegrees = (line.id.charCodeAt(0) * 9) % 360
    context.strokeStyle = "hsl(#{hueDegrees}deg 50% 50%)"
    context.lineWidth = @_pixelSize * 2
    context.beginPath()
    
    points = line.points
    
    context.moveTo points[0].x + 0.5, points[0].y + 0.5
    context.lineTo points[i].x + 0.5, points[i].y + 0.5 for i in [1...line.points.length]
    context.lineTo points[0].x + 0.5, points[0].y + 0.5 if line.isClosed
    
    context.stroke()
    
  _drawDiagonal: (context, pointA, pointB) ->
    context.strokeStyle = diagonalColor
    context.lineWidth = @_pixelSize * 3
    context.beginPath()
    
    PAG.Point.setDiagonalLine pointA, pointB, _diagonalLine
    
    context.moveTo _diagonalLine.start.x + 0.5, _diagonalLine.start.y + 0.5
    context.lineTo _diagonalLine.end.x + 0.5, _diagonalLine.end.y + 0.5
    
    context.stroke()
