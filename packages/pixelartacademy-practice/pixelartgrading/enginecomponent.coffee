AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

deepCoreColor = "hsl(100deg 50% 50% / 50%)"
shallowCoreColor = "hsl(60deg 50% 50% / 40%)"
pointColor = "hsl(350deg 50% 50%)"
edgeColor = "hsl(200deg 50% 50% / 50%)"
getStraightLineColor = (opacity) -> "hsl(60deg 50% 50% / #{opacity})"
straightLineColor = getStraightLineColor 1
curveColor = "hsl(100deg 50% 50% / 100%)"

_straightLine = new THREE.Line2
_pointPosition = new THREE.Vector3
_pointPositionOnLine = new THREE.Vector3

class PAG.EngineComponent
  @debug = true
  
  constructor: (@options) ->
    @ready = new ComputedField =>
      return unless @options.pixelArtGrading()

      true
      
    @showPotentialParts = new ReactiveField false
    
    if @constructor.debug
      $(document).on 'keydown', (event) =>
        return unless event.which is Artificial.Control.Keys.forwardSlash
        
        @showPotentialParts not @showPotentialParts()

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
    
    # Draw line parts.
    linePartsProperty = if @showPotentialParts() then 'potentialParts' else 'parts'
    
    for line in pixelArtGrading.lines
      for part in line[linePartsProperty]
        @_drawStraightLine context, part if part instanceof PAG.Line.Part.StraightLine
        @_drawCurve context, part, true if part instanceof PAG.Line.Part.Curve

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
  
  _drawStraightLine: (context, straightLine) ->
    context.strokeStyle = straightLineColor
    context.lineWidth = @_pixelSize * 3
    context.beginPath()
    
    context.moveTo straightLine.displayLine2.start.x + 0.5, straightLine.displayLine2.start.y + 0.5
    context.lineTo straightLine.displayLine2.end.x + 0.5, straightLine.displayLine2.end.y + 0.5
    
    context.stroke()
    
  _drawCurve: (context, curve) ->
    context.strokeStyle = curveColor
    context.lineWidth = @_pixelSize * 3
    context.beginPath()
    
    points = curve.displayPoints
    getPoint = (index) => if curve.isClosed then points[_.modulo index, points.length - 1] else points[index]
    
    context.moveTo points[0].position.x + 0.5, points[0].position.y + 0.5
    
    endIndex = if curve.isClosed then points.length - 1 else points.length - 2
    
    for pointIndex in [0..endIndex]
      start = getPoint pointIndex
      end = getPoint pointIndex + 1
      @_bezierCurve context, start.controlPoints.after, end.controlPoints.before, end.position
      
    context.stroke()
  
  _bezierCurve: (context, controlPoint1, controlPoint2, end) ->
    context.bezierCurveTo controlPoint1.x + 0.5, controlPoint1.y + 0.5, controlPoint2.x + 0.5, controlPoint2.y + 0.5, end.x + 0.5, end.y + 0.5
