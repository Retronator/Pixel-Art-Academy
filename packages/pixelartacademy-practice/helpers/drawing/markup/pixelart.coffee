LOI = LandsOfIllusions
PAA = PixelArtAcademy

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
  @pixelPerfectLineErrors: (line, doubles = true, corners = true) ->
    markup = []
    
    pixelPerfectLineErrors = []
    pixelPerfectLineErrors.push line.getDoubles()... if doubles
    pixelPerfectLineErrors.push line.getCorners()... if corners
    
    pixelPerfectErrorBase = style: Markup.errorStyle()
    
    for error in pixelPerfectLineErrors
      markup.push
        pixel: _.extend {}, pixelPerfectErrorBase, _.pick error, 'x', 'y'
        
    markup
  
  @impliedLineBase: ->
    palette = LOI.palette()
    lineColor = palette.color Atari2600.hues.azure, 5
    
    style: "##{lineColor.getHexString()}"
  
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
    
  @impliedLine: (line) ->
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
    
    line: _.extend @impliedLineBase(), {points}
  
  @impliedStraightLine: (straightLine) ->
    line: _.extend @impliedLineBase(),
      points: [
        x: straightLine.displayLine2.start.x + 0.5, y: straightLine.displayLine2.start.y + 0.5
      ,
        x: straightLine.displayLine2.end.x + 0.5, y: straightLine.displayLine2.end.y + 0.5
      ]
  
  @evaluatedImpliedStraightLine: (straightLine) ->
    @_prepareLineParts straightLine
    
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
    
  @_prepareLineParts: (straightLine) ->
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
    # Note: We don't have the PAG shorthand since helpers are included before pixel art evaluation.
    SegmentLengths = PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine.SegmentLengths
    evaluation = straightLine.evaluate()
    
    switch evaluation.segmentLengths.type
      when SegmentLengths.Even then Markup.betterStyle()
      when SegmentLengths.Alternating then Markup.mediocreStyle()
      when SegmentLengths.Broken then Markup.worseStyle()
      
  @segmentLengthTexts: (linePart) ->
    textBase = Markup.textBase()
    
    markup = []

    # Prepare to write text as soon as we know where to position the text.
    numberAppearsAboveSegment = null
    texts = []
    
    processTexts = ->
      while text = texts.pop()
        if numberAppearsAboveSegment
          position = x: text.segmentCenter.x + 0.5, y: text.segmentCenter.y, origin: Markup.TextOriginPosition.BottomCenter
          
        else
          position = x: text.segmentCenter.x, y: text.segmentCenter.y + 0.5, origin: Markup.TextOriginPosition.MiddleRight
        
        markup.push
          text: _.extend {}, textBase,
            position: position
            value: "#{text.number}"
    
    addText = (segmentCenter, number) ->
      texts.push {segmentCenter, number}
      return unless numberAppearsAboveSegment?
      
      processTexts()
      
    for segmentIndex in [linePart.startSegmentIndex..linePart.endSegmentIndex]
      segment = linePart.line.getEdgeSegment segmentIndex
      continue unless segment.pointSegmentsCount
      
      startPointIndex = segment.pointSegmentsStartPointIndex
      endPointIndex = segment.pointSegmentsEndPointIndex
      
      startPointIndex = Math.max startPointIndex, linePart.startPointIndex if segmentIndex is linePart.startSegmentIndex
      endPointIndex = Math.min endPointIndex, linePart.endPointIndex if segmentIndex is linePart.endSegmentIndex
      
      pointSegmentLength = if segmentIndex in [linePart.startSegmentIndex, linePart.endSegmentIndex] then segment.externalPointSegmentLength else segment.pointSegmentLength

      if pointSegmentLength > 1
        # We have one long segment.
        startPoint = linePart.line.getPoint startPointIndex
        endPoint = linePart.line.getPoint endPointIndex
        
        numberAppearsAboveSegment = endPoint.x isnt startPoint.x
        
        segmentCenter =
          x: (startPoint.x + endPoint.x) / 2
          y: (startPoint.y + endPoint.y) / 2
        
        addText segmentCenter, pointSegmentLength
        
      else
        # We have multiple points.
        for pointIndex in [startPointIndex..endPointIndex]
          point = linePart.line.getPoint pointIndex
          addText point, 1
      
    # If we haven't figured out where to write the text yet, default to top.
    if texts.length
      numberAppearsAboveSegment = true
      processTexts()
      
    markup
    
  @lineEvaluationPercentageTexts: (straightLine) ->
    @_prepareLineParts straightLine
    
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
      @evaluatedImpliedStraightLine(straightLine)...
      @segmentLengthTexts(straightLine)...
      @lineEvaluationPercentageTexts(straightLine)...
    ]
    
    markup
