LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Note: We don't have the PAE shorthand since helpers are included before pixel art evaluation.

Atari2600 = LOI.Assets.Palette.Atari2600
Markup = PAA.Practice.Helpers.Drawing.Markup

_evaluationToCanvasOffset = new THREE.Vector2 0.5, 0.5

_start = new THREE.Vector2
_end = new THREE.Vector2
_centralPartStart = new THREE.Vector2
_centralPartEnd = new THREE.Vector2
_normal = new THREE.Vector2
_normalLeft = new THREE.Vector2
_normalRight = new THREE.Vector2
_startPart = new THREE.Vector2
_centralPart = new THREE.Vector2
_endPart = new THREE.Vector2
_startPartCenter = new THREE.Vector2
_centralPartCenter = new THREE.Vector2
_endPartCenter = new THREE.Vector2

_textPosition = new THREE.Vector2

class Markup.PixelArt
  @OffsetDirections:
    Up: 'Up'
    UpLeft: 'UpLeft'
    Left: 'Left'
  
  @pixelPerfectLineErrors: (line, doubles = true, corners = true, pixelArtEvaluationProperty = null) ->
    markup = []
    
    pixelPerfectLineErrors = []
    pixelPerfectLineErrors.push line.getDoubles(pixelArtEvaluationProperty)... if doubles
    pixelPerfectLineErrors.push line.getCorners(pixelArtEvaluationProperty)... if corners
    
    pixelPerfectErrorBase = style: Markup.errorStyle()
    
    for error in pixelPerfectLineErrors
      markup.push
        pixel: _.extend {}, pixelPerfectErrorBase, _.pick error, 'x', 'y'
        
    markup
  
  @intendedLineBase: ->
    palette = LOI.palette()
    lineColor = palette.color Atari2600.hues.gray, 4
    
    style: "##{lineColor.getHexString()}"
    width: 0
  
  @perceivedLineBase: ->
    palette = LOI.palette()
    lineColor = palette.color Atari2600.hues.azure, 5
    
    style: "##{lineColor.getHexString()}"
    cap: 'round'
  
  @diagonalRatioText: (straightLine) ->
    evaluation = straightLine.evaluate()
    
    startPoint = _.first straightLine.points
    endPoint = _.last straightLine.points
    rightPoint = if endPoint.x > startPoint.x then endPoint else startPoint
    
    text: _.extend Markup.textBase(),
      position:
        x: rightPoint.x + 1.5, y: rightPoint.y, origin: Markup.TextOriginPosition.BottomLeft
      value: "#{evaluation.diagonalRatio.numerator}:#{evaluation.diagonalRatio.denominator}"
    
  @evaluatedDiagonalRatioText: (straightLine) ->
    element = @diagonalRatioText straightLine
    element.text.style = @evaluatedSegmentLengthsStyle straightLine
    element
    
  # This line connects corners of line segments to perfectly match the actual pixels.
  @segmentedPerceivedLine: (line) ->
    # Add points at the extents of each edge segments.
    points = [
      line.getPoint line.edgeSegments[0].startPointIndex
    ]
    
    for edgeSegment in line.edgeSegments
      points.push line.getPoint edgeSegment.endPointIndex
      
    # Create modifiable points (offset to the center of the pixels).
    points = for point in points
      x: point.x + 0.5
      y: point.y + 0.5
      
    # Move points of diagonal segments to the segment corners.
    for edgeSegment, index in line.edgeSegments when not edgeSegment.edge.isAxisAligned
      startToEndOffsetX = 0.5 * Math.sign points[index + 1].x - points[index].x
      startToEndOffsetY = 0.5 * Math.sign points[index + 1].y - points[index].y
      
      if index > 0
        points[index].x += startToEndOffsetX
        points[index].y += startToEndOffsetY

      if index < line.edgeSegments.length - 1
        points[index + 1].x -= startToEndOffsetX
        points[index + 1].y -= startToEndOffsetY
    
    line: _.extend @perceivedLineBase(), {points}
    
  # This line is a smooth interpretation of the perceived line based on line parts.
  @perceivedLine: (line) ->
    @perceivedLinePart linePart for linePart in line.parts
    
  @perceivedLinePart: (linePart) ->
    switch
      when linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine then @perceivedStraightLine linePart
      when linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.Curve then @perceivedCurve linePart
      else null
  
  @perceivedStraightLine: (straightLine) ->
    line: _.extend @perceivedLineBase(),
      points: [
        x: straightLine.displayLine2.start.x + 0.5, y: straightLine.displayLine2.start.y + 0.5
      ,
        x: straightLine.displayLine2.end.x + 0.5, y: straightLine.displayLine2.end.y + 0.5
      ]
      
  @perceivedCurve: (curve) ->
    startPosition = curve.displayPoints[0].position
    points = [x: startPosition.x + 0.5, y: startPosition.y + 0.5]

    getCurvePoint = (index) => if curve.isClosed then curve.displayPoints[_.modulo index, curve.displayPoints.length - 1] else curve.displayPoints[index]
    endIndex = if curve.isClosed then curve.displayPoints.length - 1 else curve.displayPoints.length - 2
    
    for pointIndex in [0..endIndex]
      start = getCurvePoint pointIndex
      end = getCurvePoint pointIndex + 1
      
      points.push
        x: end.position.x + 0.5
        y: end.position.y + 0.5
        bezierControlPoints: [
          x: start.controlPoints.after.x + 0.5
          y: start.controlPoints.after.y + 0.5
        ,
          x: end.controlPoints.before.x + 0.5
          y: end.controlPoints.before.y + 0.5
        ]
    
    line: _.extend @perceivedLineBase(), {points}
  
  @evaluatedPerceivedStraightLine: (straightLine) ->
    @_prepareStraightLineParts straightLine
    
    evaluation = straightLine.evaluate()
    markup = []
    
    if straightLine.startPointSegmentLength
      markup.push
        line:
          points: [_start.clone(), _centralPartStart.clone()]
          style: if evaluation.endSegments.startScore is 1 then Markup.betterStyle() else Markup.worseStyle()
    
    if straightLine.endPointSegmentLength
      markup.push
        line:
          points: [_centralPartEnd.clone(), _end.clone()]
          style: if evaluation.endSegments.endScore is 1 then Markup.betterStyle() else Markup.worseStyle()
      
    markup.push
      line:
        points: [_centralPartStart.clone(), _centralPartEnd.clone()]
        style: @evaluatedSegmentLengthsStyle straightLine
 
    markup
    
  @_prepareStraightLineParts: (straightLine) ->
    _start.copy(straightLine.displayLine2.start).add _evaluationToCanvasOffset
    _end.copy(straightLine.displayLine2.end).add _evaluationToCanvasOffset
    
    _centralPartStart.copy _start
    _centralPartEnd.copy _end

    _normal.subVectors _end, _start
    _normal.normalize()
    _normalRight.set _normal.y, -_normal.x
    _normalLeft.set -_normal.y, _normal.x
    
    if straightLine.startPointSegmentLength
      _startPart.copy(_normal).multiplyScalar Math.sqrt(1 + straightLine.startPointSegmentLength ** 2)
      _centralPartStart.add _startPart
    
    if straightLine.endPointSegmentLength
      _endPart.copy(_normal).multiplyScalar Math.sqrt(1 + straightLine.endPointSegmentLength ** 2)
      _centralPartEnd.sub _endPart

    _centralPart.subVectors _centralPartEnd, _centralPartStart

    _startPartCenter.copy(_startPart).multiplyScalar(0.5).add _start
    _centralPartCenter.copy(_centralPart).multiplyScalar(0.5).add _centralPartStart
    _endPartCenter.copy(_endPart).multiplyScalar(0.5).add _centralPartEnd

  @evaluatedSegmentCornerLines: (straightLine) ->
    evaluation = straightLine.evaluate()
    
    if straightLine.startPointSegmentLength
      startStyle = if evaluation.endSegments.startScore is 1 then Markup.betterStyle() else Markup.worseStyle()
    
    if straightLine.endPointSegmentLength
      endStyle = if evaluation.endSegments.endScore is 1 then Markup.betterStyle() else Markup.worseStyle()
    
    middleStyle = @evaluatedSegmentLengthsStyle straightLine

    segmentCorners = straightLine.getSegmentCorners()
    markup = []
    
    for side in ['left', 'right']
      points = segmentCorners[side]
      
      for point in points
        point.x += 0.5
        point.y += 0.5
  
      if startStyle
        markup.push
          line:
            points: points[0..1]
            style: startStyle
            
      if endStyle
        markup.push
          line:
            points: points[points.length - 2..points.length - 1]
            style: endStyle
        
      markup.push
        line:
          points: points[(if startStyle then 1 else 0)..points.length - (if endStyle then 2 else 1)]
          style: middleStyle
    
    markup
  
  @evaluatedSegmentLengthsStyle: (straightLine) ->
    SegmentLengths = PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine.SegmentLengths
    evaluation = straightLine.evaluate()
    
    switch evaluation.segmentLengths.type
      when SegmentLengths.Even then Markup.betterStyle()
      when SegmentLengths.Alternating then Markup.mediocreStyle()
      when SegmentLengths.Broken then Markup.worseStyle()
      
  @pointSegmentLengthTexts: (lineOrLinePart, options = {}) ->
    textBase = Markup.textBase()
    
    texts = []
    
    if lineOrLinePart instanceof PAA.Practice.PixelArtEvaluation.Line
      line = lineOrLinePart
      startSegmentIndex = 0
      endSegmentIndex = line.edgeSegments.length - 1
      
    else
      linePart = lineOrLinePart
      line = linePart.line
      startSegmentIndex = linePart.startSegmentIndex
      endSegmentIndex = linePart.endSegmentIndex
      
    for segmentIndex in [startSegmentIndex..endSegmentIndex]
      segment = line.getEdgeSegment segmentIndex
      continue unless segment.pointSegmentsCount
      
      startPointIndex = segment.pointSegmentsStartPointIndex
      endPointIndex = segment.pointSegmentsEndPointIndex
      
      if linePart
        startPointIndex = Math.max startPointIndex, linePart.startPointIndex if segmentIndex is startSegmentIndex
        endPointIndex = Math.min endPointIndex, linePart.endPointIndex if segmentIndex is endSegmentIndex
      
        pointSegmentLength = if segmentIndex in [startSegmentIndex, endSegmentIndex] then segment.externalPointSegmentLength else segment.pointSegmentLength
        
      else
        pointSegmentLength = segment.pointSegmentLength

      if pointSegmentLength > 1
        # We have one long segment.
        startPoint = line.getPoint startPointIndex
        endPoint = line.getPoint endPointIndex
        
        numberAppearsAboveSegment = endPoint.x isnt startPoint.x
        
        segmentCenter =
          x: (startPoint.x + endPoint.x) / 2
          y: (startPoint.y + endPoint.y) / 2
        
        texts.push
          segmentCenter: segmentCenter
          number: pointSegmentLength
          offsetDirection: if numberAppearsAboveSegment then @OffsetDirections.Up else @OffsetDirections.Left
        
      else
        # We have multiple points.
        for pointIndex in [startPointIndex..endPointIndex]
          point = line.getPoint pointIndex
          
          texts.push
            segmentCenter: point
            number: 1
            
    # Determine positions for single segments.
    for text, index in texts when not text.offsetDirection
      previousOffsetDirection = null
      nextOffsetDirection = null
      
      for previousIndex in [index - 1..0] by -1
        if previousOffsetDirection = texts[previousIndex].offsetDirection
          break
          
      for nextIndex in [index + 1...texts.length]
        if nextOffsetDirection = texts[nextIndex].offsetDirection
          break
          
      unless previousOffsetDirection or nextOffsetDirection
        # We couldn't find any direction preference, default to up.
        text.offsetDirection = @OffsetDirections.Up
        
      else if previousOffsetDirection is nextOffsetDirection
        # Preserve direction in between segments with the same direction.
        text.offsetDirection = previousOffsetDirection
        
      else unless previousOffsetDirection and nextOffsetDirection
        # Use the only provided direction or default to up when no direction is set at all.
        text.offsetDirection = previousOffsetDirection or nextOffsetDirection or @OffsetDirections.Up
        
      else
        # Use diagonal offset to transition between different orientations when there is empty space up-left.
        previousText = texts[index - 1]
        previousTextIsInTheUpLeftArea = previousText.segmentCenter.x < text.segmentCenter.x and previousText.segmentCenter.y < text.segmentCenter.y
        
        nextText = texts[index + 1]
        nextTextIsInTheUpLeftArea = nextText.segmentCenter.x < text.segmentCenter.x and nextText.segmentCenter.y < text.segmentCenter.y
        
        if previousTextIsInTheUpLeftArea or nextTextIsInTheUpLeftArea
          text.offsetDirection = @OffsetDirections.Up
        
        else
          text.offsetDirection = @OffsetDirections.UpLeft
    
    # Create markup for texts.
    markup = []
    
    if options.abruptEvaluation
      betterStyle = Markup.betterStyle()
      mediocreStyle = Markup.mediocreStyle()
      worseStyle = Markup.worseStyle()

      {pointSegmentLengthChanges} = linePart.evaluate()
    
    AbruptSegmentLengthChanges = PAA.Practice.PixelArtEvaluation.Subcriteria.SmoothCurves.AbruptSegmentLengthChanges
    MajorAbruptSegmentLengthChanges = PAA.Practice.PixelArtEvaluation.Line.Part.Curve.AbruptSegmentLengthChanges.Major
    MinorAbruptSegmentLengthChanges = PAA.Practice.PixelArtEvaluation.Line.Part.Curve.AbruptSegmentLengthChanges.Minor

    for text, pointSegmentIndex in texts
      switch text.offsetDirection
        when @OffsetDirections.Up
          position = x: text.segmentCenter.x + 0.5, y: text.segmentCenter.y, origin: Markup.TextOriginPosition.BottomCenter
        
        when @OffsetDirections.UpLeft
          position = x: text.segmentCenter.x, y: text.segmentCenter.y, origin: Markup.TextOriginPosition.BottomRight

        when @OffsetDirections.Left
          position = x: text.segmentCenter.x, y: text.segmentCenter.y + 0.5, origin: Markup.TextOriginPosition.MiddleRight
      
      element =
        position: position
        value: "#{text.number}"
        
      if options.abruptEvaluation
        element.style = betterStyle
        
        abruptChangesAtIndex = _.filter pointSegmentLengthChanges.abruptPointSegmentLengthChanges, (change) => change.index in [pointSegmentIndex, pointSegmentIndex - 1]
        
        if biggestAbruptChange = _.maxBy abruptChangesAtIndex, (change) => change.abruptIncrease
          if biggestAbruptChange.abruptIncrease >= PAA.Practice.PixelArtEvaluation.Line.Part.Curve.majorAbruptIncreaseThreshold
            # This is a major abrupt change.
            continue if options.abruptFilterValue and options.abruptFilterValue not in [AbruptSegmentLengthChanges, MajorAbruptSegmentLengthChanges]
            element.style = worseStyle

          else if biggestAbruptChange.abruptIncrease
            # This is a minor abrupt change.
            continue if options.abruptFilterValue and options.abruptFilterValue not in [AbruptSegmentLengthChanges, MinorAbruptSegmentLengthChanges]
            element.style = mediocreStyle
            
        else
          continue if options.abruptFilterValue
        
      markup.push text: _.defaults element, textBase
      
    markup
    
  @straightLineEvaluationPercentageTexts: (straightLine) ->
    @_prepareStraightLineParts straightLine
    
    textBase = Markup.textBase()
    
    evaluation = straightLine.evaluate()
    markup = []
    
    # Determine the direction of the offset from the line and text origin.
    if Math.abs(straightLine.line2.end.x - straightLine.line2.start.x) < Math.abs(straightLine.line2.end.y - straightLine.line2.start.y)
      # We're on a vertical line. If we're going top to bottom, we have to offset to the left.
      normal = if straightLine.line2.end.y > straightLine.line2.start.y then _normalRight else _normalLeft
    
    else
      # We're on a horizontal line. If we're going left to right, we have to offset to the right.
      normal = if straightLine.line2.end.x > straightLine.line2.start.x then _normalLeft else _normalRight
      
    if (normal.x > 0) is (normal.y > 0)
      # The offset is on the top-left to bottom-right diagonal. Since we never
      # go towards top-left, we can assume that's where the origin should be.
      origin = Markup.TextOriginPosition.TopLeft
      
    else
      # The offset is on the top-right to bottom-left diagonal. See if we're going left or right.
      origin = if normal.x > 0 then Markup.TextOriginPosition.BottomLeft else Markup.TextOriginPosition.TopRight
    
    # Write percentages.
    distanceFromLine = 1
    
    if straightLine.startPointSegmentLength
      _textPosition.copy(normal).multiplyScalar(distanceFromLine).add _startPartCenter
      position = _.extend _textPosition.clone(), {origin}
      
      markup.push
        text: _.extend {}, textBase,
          position: position
          value: Markup.percentage evaluation.endSegments.startScore
          style: if evaluation.endSegments.startScore is 1 then Markup.betterStyle() else Markup.worseStyle()
    
    if straightLine.endPointSegmentLength
      _textPosition.copy(normal).multiplyScalar(distanceFromLine).add _endPartCenter
      position = _.extend _textPosition.clone(), {origin}

      markup.push
        text: _.extend {}, textBase,
          position: position
          value: Markup.percentage evaluation.endSegments.endScore
          style: if evaluation.endSegments.endScore is 1 then Markup.betterStyle() else Markup.worseStyle()
      
    _textPosition.copy(normal).multiplyScalar(distanceFromLine).add _centralPartCenter
    position = _.extend _textPosition.clone(), {origin}

    markup.push
      text: _.extend {}, textBase,
        position: position
        value: Markup.percentage evaluation.segmentLengths.score
        style: @evaluatedSegmentLengthsStyle straightLine
    
    markup
  
  @straightLineBreakdown: (straightLine) ->
    markup = [
      @evaluatedDiagonalRatioText straightLine
      @evaluatedPerceivedStraightLine(straightLine)...
      @pointSegmentLengthTexts(straightLine)...
      @straightLineEvaluationPercentageTexts(straightLine)...
    ]
    
    markup

  @curveSmoothnessEvaluationPercentageTexts: (line, subcriterions) ->
    textBase = Markup.textBase()
    
    return [] unless curveSmoothness = line.evaluate()?.curveSmoothness
    
    score = 0
    totalWeight = 0
    
    for subcriterion, weight of PAA.Practice.PixelArtEvaluation.SubcriteriaWeights.SmoothCurves when not subcriterions or subcriterion in subcriterions
      subcriterionProperty = _.lowerFirst subcriterion
      score += curveSmoothness[subcriterionProperty].score * weight
      totalWeight += weight
      
    return [] unless totalWeight
    
    score /= totalWeight
    
    markup = []
    
    # Write the percentage to the right of the right-most pixel of the curve.
    rightMostPoint = line.getRightMostPoint()

    markup.push
      text: _.extend {}, textBase,
        position:
          x: rightMostPoint.x + 1
          y: rightMostPoint.y + 0.5
          origin: Markup.TextOriginPosition.MiddleLeft
        value: Markup.percentage score
        style: switch
          when score >= 0.9 then Markup.betterStyle()
          when score >= 0.6 then Markup.mediocreStyle()
          else Markup.worseStyle()
    
    markup
