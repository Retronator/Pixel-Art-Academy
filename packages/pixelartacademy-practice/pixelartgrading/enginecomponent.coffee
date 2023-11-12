AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

deepCoreColor = "hsl(100deg 50% 50% / 50%)"
shallowCoreColor = "hsl(60deg 50% 50% / 40%)"
pointColor = "hsl(350deg 50% 50%)"
edgeColor = "hsl(200deg 50% 50% / 50%)"
diagonalColor = "hsl(60deg 50% 50% / 100%)"
curveColor = "hsl(100deg 50% 50% / 100%)"

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
      #for diagonal in line.diagonals
      #  @_drawDiagonal context, diagonal
      
      for curve in line.curves
        @_drawCurve context, curve

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
    context.lineTo points[i].x + 0.5, points[i].y + 0.5 for i in [1...points.length]
    context.lineTo points[0].x + 0.5, points[0].y + 0.5 if line.isClosed
    
    context.stroke()
    
  _drawDiagonal: (context, diagonal) ->
    context.strokeStyle = diagonalColor
    context.lineWidth = @_pixelSize * 3
    context.beginPath()
    
    PAG.Point.setDiagonalLine diagonal.startPoint, diagonal.endPoint, _diagonalLine
    
    context.moveTo _diagonalLine.start.x + 0.5, _diagonalLine.start.y + 0.5
    context.lineTo _diagonalLine.end.x + 0.5, _diagonalLine.end.y + 0.5
    
    context.stroke()
    
  _drawCurve: (context, curve) ->
    context.strokeStyle = curveColor
    context.lineWidth = @_pixelSize * 3
    context.beginPath()
    
    points = curve.points
    getPoint = (index) => if curve.isClosed then points[_.modulo index, points.length - 1] else points[index]
    
    context.moveTo points[0].x + 0.5, points[0].y + 0.5
    
    for i in [0...points.length - 1]
      @_drawCurveBetweenPoints context, getPoint(i - 1), getPoint(i), getPoint(i + 1), getPoint(i + 2)
      
    context.stroke()
    
  _drawCurveBetweenPoints: (context, p1, p2, p3, p4) ->
    p1 ?= p2
    p4 ?= p3
    
    for t in [0.1..1] by 0.1
      x = @_catmullRom t, p1.x, p2.x, p3.x, p4.x
      y = @_catmullRom t, p1.y, p2.y, p3.y, p4.y
      context.lineTo x + 0.5, y + 0.5
  
  _catmullRom: (t, p0, p1, p2, p3) ->
    v0 = (p2 - p0) * 0.5
    v1 = (p3 - p1) * 0.5
    t2 = t * t
    t3 = t * t2
    
    (2 * p1 - 2 * p2 + v0 + v1) * t3 + (-3 * p1 + 3 * p2 - 2 * v0 - v1) * t2 + v0 * t + p1
