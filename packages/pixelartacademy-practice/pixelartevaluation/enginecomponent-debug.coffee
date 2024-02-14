AE = Artificial.Everywhere
AC = Artificial.Control
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

deepCoreColor = "hsl(100deg 50% 50% / 50%)"
shallowCoreColor = "hsl(60deg 50% 50% / 40%)"
pointColor = "hsl(350deg 50% 50%)"
edgeColor = "hsl(200deg 50% 50% / 50%)"
getStraightLineColor = (opacity) -> "hsl(60deg 50% 50% / #{opacity})"
straightLineColor = getStraightLineColor 1
curveColor = "hsl(100deg 50% 50% / 100%)"
segmentBoundaryColor = "hsl(80deg 50% 50% / 100%)"

class PAE.EngineComponent extends PAE.EngineComponent
  @debug = true
  
  constructor: (@options) ->
    super arguments...
    
    if @constructor.debug
      @drawCore = new ReactiveField false
      @drawPoints = new ReactiveField false
      @drawLines = new ReactiveField false
      @drawLineParts = new ReactiveField false
      @drawPotentialParts = new ReactiveField false
      @drawSegmentCorners = new ReactiveField false
  
      $(document).on 'keydown', (event) =>
        switch event.which
          when AC.Keys['1'] then field = @drawCore
          when AC.Keys['2'] then field = @drawPoints
          when AC.Keys['3'] then field = @drawLines
          when AC.Keys['4'] then field = @drawLineParts
          when AC.Keys['5'] then field = @drawPotentialParts
          when AC.Keys['6'] then field = @drawSegmentCorners
          
        field not field() if field

  _render: (context) ->
    super arguments...
    
    return unless @constructor.debug
    
    pixelArtEvaluation = @options.pixelArtEvaluation()

    context.save()
    context.translate 0.5, 0.5
    
    for layer in pixelArtEvaluation.layers
      if @drawCore()
        # Draw deep core pixels.
        context.beginPath()
        @_addPixelToPath context, pixel for pixel in layer.pixels when pixel.isDeepCore
        @_diagonalDash context, pixelArtEvaluation.bitmap.bounds, deepCoreColor
        
        # Draw shallow core pixels.
        context.beginPath()
        @_addPixelToPath context, pixel for pixel in layer.pixels when pixel.isShallowCore
        @_diagonalDash context, pixelArtEvaluation.bitmap.bounds, shallowCoreColor
      
      if @drawPoints()
        # Draw point network.
        for point in layer.points
          @_drawDebugEdge context, point, neighbor for neighbor in point.neighbors
        
        # Draw points.
        @_drawDebugPoint context, point for point in layer.points
      
      if @drawLines()
        # Draw lines.
        @_drawDebugLine context, line for line in layer.lines

      if @drawLineParts()
        # Draw line parts.
        linePartsProperty = if @drawPotentialParts?() then 'potentialParts' else 'parts'
        
        for line in layer.lines
          for part in line[linePartsProperty]
            @_drawDebugStraightLine context, part if part instanceof PAE.Line.Part.StraightLine
            @_drawDebugCurve context, part, true if part instanceof PAE.Line.Part.Curve
        
    context.restore()

  _drawDebugEdge: (context, pointA, pointB) ->
    context.strokeStyle = edgeColor
    context.lineWidth = @_pixelSize * 2
    context.beginPath()
    
    context.moveTo pointA.x, pointA.y
    context.lineTo pointB.x, pointB.y
    
    context.stroke()
    
  _drawDebugPoint: (context, point) ->
    context.beginPath()
    context.arc point.x, point.y, @_pixelSize * 3, 0, 2 * Math.PI
    context.fillStyle = pointColor
    context.fill()

  _drawDebugLine: (context, line) ->
    hueDegrees = (line.id * 9) % 360
    context.strokeStyle = "hsl(#{hueDegrees}deg 50% 50%)"
    context.lineWidth = @_pixelSize * 2
    context.beginPath()
    
    points = line.points
    
    context.moveTo points[0].x, points[0].y
    context.lineTo points[i].x, points[i].y for i in [1...points.length]
    context.lineTo points[0].x, points[0].y if line.isClosed
    
    context.stroke()
  
  _drawDebugStraightLine: (context, straightLine) ->
    context.strokeStyle = straightLineColor
    context.lineWidth = @_pixelSize * 3
    context.beginPath()
    
    context.moveTo straightLine.displayLine2.start.x, straightLine.displayLine2.start.y
    context.lineTo straightLine.displayLine2.end.x, straightLine.displayLine2.end.y
    
    context.stroke()
    
    return unless @drawSegmentCorners()
    
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
  
  _drawDebugCurve: (context, curve) ->
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
