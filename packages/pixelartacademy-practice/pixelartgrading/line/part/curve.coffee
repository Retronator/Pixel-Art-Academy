AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

_point = new THREE.Vector2

class PAG.Line.Part.Curve extends PAG.Line.Part
  constructor: (..., @isClosed) ->
    super arguments...

    # Create display points.
    @displayPoints = []
    
    segmentParameter = 0.5
    
    for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
      segment = @line.getEdgeSegment segmentIndex
      
      # Exclude side-step segments from generating curve points, except at end points.
      continue unless segment.pointSegmentsCount or segmentIndex in [@startSegmentIndex, @endSegmentIndex]
      
      startPointIndex = segment.startPointIndex
      endPointIndex = segment.endPointIndex
      
      startPointIndex = Math.max startPointIndex, @startPointIndex if segmentIndex is @startSegmentIndex
      endPointIndex = Math.min endPointIndex, @endPointIndex if segmentIndex is @endSegmentIndex
      
      startPoint = @line.getPoint startPointIndex
      endPoint = @line.getPoint endPointIndex
      
      unless @isClosed
        segmentParameter = switch segmentIndex
          when @startSegmentIndex then 0
          when @endSegmentIndex then 1
          else 0.5
        
      @displayPoints.push @_createDisplayPoint new THREE.Vector2().lerpVectors startPoint, endPoint, segmentParameter
      
    if @isClosed and (@displayPoints[0].x isnt @displayPoints[@displayPoints.length - 1].x or @displayPoints[0].y isnt @displayPoints[@displayPoints.length - 1].y)
      @displayPoints.push @displayPoints[0]
      
    if @displayPoints.length is 2
      startPoint = @line.getPoint @line.getEdgeSegment(@startSegmentIndex).endPointIndex
      endPoint = @line.getPoint @line.getEdgeSegment(@endSegmentIndex).startPointIndex
      
      @displayPoints.splice 1, 0, @_createDisplayPoint new THREE.Vector2().lerpVectors startPoint, endPoint, 0.5
    
    @_calculateControlPoints 0, @displayPoints.length - 1
  
  _createDisplayPoint: (position) ->
    position: position
    normal: new THREE.Vector2
    controlPoints:
      before: new THREE.Vector2
      after: new THREE.Vector2
  
  _calculateControlPoints: (displayPointStartIndex, displayPointEndIndex) ->
    for index in [displayPointStartIndex..displayPointEndIndex]
      point = @displayPoints[index]
      previousPoint = if @isClosed then @displayPoints[_.modulo index - 1, @displayPoints.length] else @displayPoints[index - 1]
      nextPoint = if @isClosed then @displayPoints[_.modulo index + 1, @displayPoints.length] else @displayPoints[index + 1]
      
      # Calculate the normal.
      unless previousPoint
        if @previousPart
          @previousPart.line2.delta point.normal
        
        else
          point.normal.subVectors nextPoint.position, point.position
          
      else unless nextPoint
        if @nextPart
          @nextPart.line2.delta point.normal
        
        else
          point.normal.subVectors point.position, previousPoint.position
          
      else
        point.normal.subVectors nextPoint.position, previousPoint.position
        
      point.normal.normalize()
      
      # Calculate control points.
      if previousPoint
        distance = point.position.distanceTo previousPoint.position
        point.controlPoints.before.copy(point.normal).multiplyScalar(-distance / 3).add point.position
        
      if nextPoint
        distance = point.position.distanceTo nextPoint.position
        point.controlPoints.after.copy(point.normal).multiplyScalar(distance / 3).add point.position
        
    # Explicit return to prevent result collection.
    null
  
  setNeighbors: ->
    super arguments...
    
    if @previousPart
      @projectToLine @startPointIndex, @previousPart, @displayPoints[0].position
      @_calculateControlPoints 0, 1
    
    if @nextPart
      @projectToLine @endPointIndex, @nextPart, @displayPoints[@displayPoints.length - 1].position
      @_calculateControlPoints @displayPoints.length - 2, @displayPoints.length - 1
      
  projectToLine: (pointIndex, straightLine, target) ->
    _point.copy @line.getPoint pointIndex
    straightLine.line2.closestPointToPoint _point, false, target
    
  calculatePointConfidence: ->
    # Create point segments.
    @pointSegments = []
    
    for startSegmentIndex in [@startSegmentIndex..@endSegmentIndex]
      edgeSegment = @_getEdgeSegment startSegmentIndex
      continue unless edgeSegment.pointSegmentsCount
      
      startPointIndex = edgeSegment.startPointIndex
      startPointIndex++ unless edgeSegment.edge.isAxisAligned or edgeSegment.hasPointSegment.before

      endSegmentIndex = startSegmentIndex
      testSegmentIndex = startSegmentIndex
      
      # Expand segment to as many segments with points while no curvature changes happen.
      loop
        break unless edgeSegment = @_getEdgeSegment testSegmentIndex
        
        if edgeSegment.pointSegmentsCount
          endSegmentIndex = testSegmentIndex
        
        break if edgeSegment.curveClockwise.after?
        
        testSegmentIndex++
        
      lastSegment = _.last @pointSegments
      continue if lastSegment and endSegmentIndex <= lastSegment.endSegmentIndex
      
      endEdgeSegment = @_getEdgeSegment endSegmentIndex
      endPointIndex = endEdgeSegment.endPointIndex
      endPointIndex-- unless endEdgeSegment.edge.isAxisAligned or endEdgeSegment.hasPointSegment.after
      
      if endPointIndex >= startPointIndex
        length = endPointIndex - startPointIndex + 1
        
      else
        length = startPointIndex + 1 + @line.points.length - endPointIndex
      
      @pointSegments.push {startSegmentIndex, endSegmentIndex, startPointIndex, endPointIndex, length}
      
    # Remove remaining side-step segments.
    pointSegmentIndex = 1

    while pointSegmentIndex < @pointSegments.length
      previousPointSegment = @_getPointSegment pointSegmentIndex - 1
      pointSegment = @_getPointSegment pointSegmentIndex
      break unless nextPointSegment = @_getPointSegment pointSegmentIndex + 1
      
      if pointSegment.length is 2 and pointSegment.startPointIndex is previousPointSegment.endPointIndex and pointSegment.endPointIndex is nextPointSegment.startPointIndex
        @pointSegments.splice pointSegmentIndex, 1
        continue
        
      pointSegmentIndex++
      
    # Shorten overlapping segments.
    for pointSegment, pointSegmentIndex in @pointSegments
      continue unless previousPointSegment = @_getPointSegment pointSegmentIndex - 1
      continue unless pointSegment.startPointIndex is previousPointSegment.endPointIndex
      pointSegment.startPointIndex++
      pointSegment.length--

    # Calculate point confidences.
    @pointConfidences = []
    
    for pointSegment, pointSegmentIndex in @pointSegments
      # Start by being confident in the points by default.
      if pointSegment.endPointIndex >= pointSegment.startPointIndex
        @pointConfidences[pointIndex] = true for pointIndex in [pointSegment.startPointIndex..pointSegment.endPointIndex]
        
      else
        @pointConfidences[pointIndex] = true for pointIndex in [0..pointSegment.endPointIndex]
        @pointConfidences[pointIndex] = true for pointIndex in [pointSegment.startPointIndex...@line.points.length]
      
      # If we're on the longer segment than the two neighbors combined (+2), we need to break the curve.
      maxPointSegmentLength = 0

      angle = @_getEdgeSegment(pointSegment.startSegmentIndex).edge.angle()
      
      if previousPointSegment = @_getPointSegment pointSegmentIndex - 1
        previousAngle = @_getEdgeSegment(previousPointSegment.startSegmentIndex).edge.angle()
        
        if _.angleDistance(angle, previousAngle) > 1
          startConfidentPointsCount = 1
        
        else
          startConfidentPointsCount = previousPointSegment.length + 1
        
        maxPointSegmentLength += startConfidentPointsCount
      
      if nextPointSegment = @_getPointSegment pointSegmentIndex + 1
        nextAngle = @_getEdgeSegment(nextPointSegment.startSegmentIndex).edge.angle()
        
        if _.angleDistance(angle, nextAngle) > 1
          endConfidentPointsCount = 1
          
        else
          endConfidentPointsCount = nextPointSegment.length + 1
        
        maxPointSegmentLength += endConfidentPointsCount
      
      continue if pointSegment.length <= maxPointSegmentLength
      
      unconfidentStartPointIndex = pointSegment.startPointIndex
      unconfidentStartPointIndex += startConfidentPointsCount if previousPointSegment
      
      unconfidentEndPointIndex = pointSegment.endPointIndex
      unconfidentEndPointIndex -= endConfidentPointsCount if nextPointSegment
      
      unconfidentStartPointIndex = _.modulo unconfidentStartPointIndex, @line.points.length
      unconfidentEndPointIndex = _.modulo unconfidentEndPointIndex, @line.points.length
      
      if unconfidentEndPointIndex >= unconfidentStartPointIndex
        @pointConfidences[pointIndex] = false for pointIndex in [unconfidentStartPointIndex..unconfidentEndPointIndex]
        
      else
        @pointConfidences[pointIndex] = false for pointIndex in [0..unconfidentEndPointIndex]
        @pointConfidences[pointIndex] = false for pointIndex in [unconfidentStartPointIndex...@line.points.length]
        
  _getPointSegment: (index) ->
    if @isClosed then @pointSegments[_.modulo index, @pointSegments.length] else @pointSegments[index]
    
  _getEdgeSegment: (index) ->
    return null unless @isClosed or @startSegmentIndex <= index <= @endSegmentIndex

    @line.getEdgeSegment index
