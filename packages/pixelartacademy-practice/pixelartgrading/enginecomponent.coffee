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
segmentBoundaryColor = "hsl(80deg 50% 50% / 100%)"

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
    
    context.save()
    context.translate 0.5, 0.5
    
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
    
    context.restore()

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
    
    context.moveTo pointA.x, pointA.y
    context.lineTo pointB.x, pointB.y
    
    context.stroke()
    
  _drawPoint: (context, point) ->
    context.beginPath()
    context.arc point.x, point.y, @_pixelSize * 3, 0, 2 * Math.PI
    context.fillStyle = pointColor
    context.fill()

  _drawLine: (context, line) ->
    hueDegrees = (line.id.charCodeAt(0) * 9) % 360
    context.strokeStyle = "hsl(#{hueDegrees}deg 50% 50%)"
    context.lineWidth = @_pixelSize * 2
    context.beginPath()
    
    points = line.points
    
    context.moveTo points[0].x, points[0].y
    context.lineTo points[i].x, points[i].y for i in [1...points.length]
    context.lineTo points[0].x, points[0].y if line.isClosed
    
    context.stroke()
  
  _drawStraightLine: (context, straightLine) ->
    context.strokeStyle = straightLineColor
    context.lineWidth = @_pixelSize * 3
    context.beginPath()
    
    context.moveTo straightLine.displayLine2.start.x, straightLine.displayLine2.start.y
    context.lineTo straightLine.displayLine2.end.x, straightLine.displayLine2.end.y
    
    context.stroke()
    
    context.strokeStyle = segmentBoundaryColor
    context.lineWidth = @_pixelSize * 2
    segmentCorners = straightLine.getSegmentCorners()
    
    for side in ['left', 'right']
      points = segmentCorners[side]
      
      context.beginPath()
      context.moveTo points[0].x, points[0].y
      
      for point in points[1..]
        context.lineTo point.x, point.y
        
      context.stroke()
  
  _drawCurve: (context, curve) ->
    context.strokeStyle = curveColor
    context.lineWidth = @_pixelSize * 3
    context.beginPath()
    
    points = curve.displayPoints
    getPoint = (index) => if curve.isClosed then points[_.modulo index, points.length - 1] else points[index]
    
    context.moveTo points[0].position.x, points[0].position.y
    
    endIndex = if curve.isClosed then points.length - 1 else points.length - 2
    
    for pointIndex in [0..endIndex]
      start = getPoint pointIndex
      end = getPoint pointIndex + 1
      @_bezierCurve context, start.controlPoints.after, end.controlPoints.before, end.position
      
    context.stroke()
  
  _bezierCurve: (context, controlPoint1, controlPoint2, end) ->
    context.bezierCurveTo controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, end.x, end.y
