AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

Atari2600 = LOI.Assets.Palette.Atari2600
Markup = PAA.Practice.Helpers.Drawing.Markup

abruptSegmentLengthChangesFilterValues = [PAE.Subcriteria.SmoothCurves.AbruptSegmentLengthChanges, _.keys(PAE.Line.Part.Curve.AbruptSegmentLengthChanges)...]
straightPartsFilters = [PAE.Subcriteria.SmoothCurves.StraightParts, _.keys(PAE.Line.Part.Curve.StraightParts)...]
inflectionPointsFilterValues = [PAE.Subcriteria.SmoothCurves.InflectionPoints, _.keys(PAE.Line.Part.Curve.InflectionPoints)...]

_offsetDirection = new THREE.Vector2

class PAE.EngineComponent extends PAA.Practice.Helpers.Drawing.Markup.EngineComponent
  @debug = true
  
  constructor: ->
    super arguments...
    
    @ready = new ComputedField =>
      return unless @options.pixelArtEvaluation()
      return unless LOI.palette()

      true

  drawToContext: (context, renderOptions = {}) ->
    return unless @ready()
    
    @_pixelSize = 1 / renderOptions.camera.effectiveScale()
    
    @_render context, renderOptions

  _render: (context, renderOptions) ->
    pixelArtEvaluation = @options.pixelArtEvaluation()
    
    displayedCriteria = @options.displayedCriteria()
    filterValue = @options.filterValue()
    focusedPixel = @options.focusedPixel()
    
    betterStyle = Markup.betterStyle()
    mediocreStyle = Markup.mediocreStyle()
    worseStyle = Markup.worseStyle()
    
    markup = []

    # Prepare lines and line parts for markup.
    focusedLines = if focusedPixel then pixelArtEvaluation.getLinesAt focusedPixel.x, focusedPixel.y else []
    focusedLineParts = if focusedPixel then pixelArtEvaluation.getLinePartsAt focusedPixel.x, focusedPixel.y else []
    lines = []
    lineParts = []
    
    for layer in pixelArtEvaluation.layers
      for line in layer.lines
        lines.push line
        
        for part in line.parts
          # Filter to evaluated property if needed.
          continue if filterValue and part.evaluate()[filterValue.property]?.type isnt filterValue.value
  
          lineParts.push part
    
    # Add markup for pixel-perfect lines.
    if PAE.Criteria.PixelPerfectLines in displayedCriteria
      for line in lines
        continue if focusedLines.length and line not in focusedLines
        
        # Draw doubles and corners.
        drawDoubles = if filterValue then filterValue is PAE.Subcriteria.PixelPerfectLines.Doubles else true
        drawCorners = if filterValue then filterValue is PAE.Subcriteria.PixelPerfectLines.Corners else true
        
        markup.push Markup.PixelArt.pixelPerfectLineErrors(line, drawDoubles, drawCorners)...
        
    # Add markup for even diagonals.
    if PAE.Criteria.EvenDiagonals in displayedCriteria
      for linePart in lineParts when linePart instanceof PAE.Line.Part.StraightLine
        if linePart in focusedLineParts
          markup.push Markup.PixelArt.straightLineBreakdown(linePart)...
          
        else
          markup.push Markup.PixelArt.evaluatedPerceivedStraightLine(linePart)...
      
      # If we're not going to be drawing curves, draw a faint unevaluated outline to indicate they were detected.
      unless PAE.Criteria.SmoothCurves in displayedCriteria
        for linePart in lineParts when linePart instanceof PAE.Line.Part.Curve
          curveMarkup = Markup.PixelArt.perceivedCurve linePart
          curveMarkup.line.width = 0
          markup.push curveMarkup
          
    # Add markup for smooth curves.
    if PAE.Criteria.SmoothCurves in displayedCriteria
      # Draw perceived lines.
      if filterValue in inflectionPointsFilterValues
        # When focusing on inflection points, we draw just the curvature curve parts.
        for line in lines
          # Ignore lines without curves.
          {curveSmoothness} = line.evaluate()
          continue unless curveSmoothness?.inflectionPoints.points.length
          
          for curve in line.curvatureCurveParts
            perceivedLineMarkup = Markup.PixelArt.perceivedCurve curve
            perceivedLineMarkup.line.arrow = end: true
            perceivedLineMarkup.line.style = betterStyle
            
            # Color the line according to the spacing score of the closest inflection point.
            closestInflectionPoint = _.minBy curveSmoothness.inflectionPoints.points, (point) =>
              # Constraint to points inside the curve bounds.
              if curve.startSegmentIndex <= point.inflectionArea.averageEdgeSegmentIndex <= curve.endSegmentIndex
                distanceToStartSegment = point.inflectionArea.averageEdgeSegmentIndex - curve.startSegmentIndex
                distanceToEndSegment = curve.endSegmentIndex - point.inflectionArea.averageEdgeSegmentIndex
                point._distanceToClosestInflectionPoint = Math.min distanceToStartSegment, distanceToEndSegment
                
              else
                point._distanceToClosestInflectionPoint = Number.POSITIVE_INFINITY
                
              point._distanceToClosestInflectionPoint
              
            # Skip lines that don't overlap an infliction point.
            continue if closestInflectionPoint._distanceToClosestInflectionPoint is Number.POSITIVE_INFINITY
            
            perceivedLineMarkup.line.style = switch
              when closestInflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.dense then worseStyle
              when closestInflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.sparse then mediocreStyle
              else betterStyle
              
            # Apply filtering.
            if PAE.Line.Part.Curve.InflectionPoints[filterValue]
              if closestInflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.dense
                continue unless filterValue is PAE.Line.Part.Curve.InflectionPoints.Dense
                
              else if closestInflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.sparse
                continue unless filterValue is PAE.Line.Part.Curve.InflectionPoints.Sparse
              
              else
                continue unless filterValue is PAE.Line.Part.Curve.InflectionPoints.Isolated
                
              
            perceivedLineMarkup.line.points = @_sideOffsetLine perceivedLineMarkup.line.points, if curve.clockwise then -1.5 else 1.5
            
            markup.push perceivedLineMarkup
      
      # When focusing on abrupt changes, we don't draw curve lines, to focus better on the actual pixel lines.
      else unless filterValue in abruptSegmentLengthChangesFilterValues
        # Draw curved parts unless we're focusing on straight parts.
        unless filterValue in straightPartsFilters
          betterStyle = Markup.betterStyle()
          
          for linePart in lineParts when linePart instanceof PAE.Line.Part.Curve and linePart.line not in focusedLines
            perceivedLineMarkup = Markup.PixelArt.perceivedCurve linePart
            perceivedLineMarkup.line.style = betterStyle
            markup.push perceivedLineMarkup
            
        # Draw straight parts unless they're already drawn.
        unless PAE.Criteria.EvenDiagonals in displayedCriteria
          for linePart in lineParts when linePart instanceof PAE.Line.Part.StraightLine and linePart.line not in focusedLines
            # Draw lines without curves with minimal lines.
            {curveSmoothness} = linePart.line.evaluate()
            unless curveSmoothness
              straightLineMarkup = Markup.PixelArt.perceivedStraightLine linePart
              straightLineMarkup.line.width = 0
              markup.push straightLineMarkup
              continue
              
            perceivedLineMarkup = Markup.PixelArt.perceivedStraightLine linePart
            
            # Straight lines at the start/end are better than in between.
            if linePart in [_.first(linePart.line.parts), _.last(linePart.line.parts)]
              perceivedLineMarkup.line.style = mediocreStyle
              continue if filterValue is PAE.Line.Part.Curve.StraightParts.Middle
              
            else
              perceivedLineMarkup.line.style = worseStyle
              continue if filterValue is PAE.Line.Part.Curve.StraightParts.End
            
            markup.push perceivedLineMarkup
      
      # Write point segment lengths.
      unless filterValue and filterValue not in abruptSegmentLengthChangesFilterValues
        pointSegmentLengthTextsOptions = abruptEvaluation: true
        
        for linePart in lineParts when linePart instanceof PAE.Line.Part.Curve
          # If a line part is focused on, don't draw point segment lengths on other parts.
          continue if focusedLineParts.length and linePart not in focusedLineParts
          
          # If we're not focused on this line specifically, only show abrupt changes, except if focusing on abrupt changes as the category.
          if filterValue is PAE.Subcriteria.SmoothCurves.AbruptSegmentLengthChanges
            pointSegmentLengthTextsOptions.abruptFilterValue = null
          
          else
            pointSegmentLengthTextsOptions.abruptFilterValue = filterValue
            pointSegmentLengthTextsOptions.abruptFilterValue ?= PAE.Subcriteria.SmoothCurves.AbruptSegmentLengthChanges unless linePart.line in focusedLines
          
          markup.push Markup.PixelArt.pointSegmentLengthTexts(linePart, pointSegmentLengthTextsOptions)...
          
      # Draw inflection points.
      unless filterValue and filterValue not in inflectionPointsFilterValues
        for line in lines
          {curveSmoothness} = line.evaluate()
          
          # Ignore lines without curves.
          continue unless curveSmoothness
          
          for inflectionPoint in curveSmoothness.inflectionPoints.points
            style = switch
              when inflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.dense then worseStyle
              when inflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.sparse then mediocreStyle
              else betterStyle
            
            # Apply filtering
            if PAE.Line.Part.Curve.InflectionPoints[filterValue]
              if inflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.dense
                continue unless filterValue is PAE.Line.Part.Curve.InflectionPoints.Dense
              
              else if inflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.sparse
                continue unless filterValue is PAE.Line.Part.Curve.InflectionPoints.Sparse
              
              else
                continue unless filterValue is PAE.Line.Part.Curve.InflectionPoints.Isolated
                
            point =
              x: inflectionPoint.position.x + 0.5
              y: inflectionPoint.position.y + 0.5
              style: style
              radius: 2
              
            markup.push {point}
          
    @drawMarkup markup, context, renderOptions

  _addPixelToPath: (context, pixel) ->
    context.rect pixel.x - 0.5, pixel.y - 0.5, 1, 1

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
  
  _bezierCurve: (context, controlPoint1, controlPoint2, end) ->
    context.bezierCurveTo controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, end.x, end.y

  _sideOffsetLine: (points, amount) ->
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
