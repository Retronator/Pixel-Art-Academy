AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

edgeVectors = {}

getEdgeVector = (x, y) ->
  edgeVectors[x] ?= {}
  
  unless edgeVectors[x][y]
    edgeVectors[x][y] = new THREE.Vector2 x, y
    edgeVectors[x][y].isAxisAligned = x is 0 or y is 0
    
  edgeVectors[x][y]
  
edgeSegmentMinPointLengthForCorner = 3

PAE.Line::classifyLineParts = ->
  # Create edges.
  for point, index in @points
    nextPoint = @points[index + 1]
    
    unless nextPoint
      break unless @isClosed

      nextPoint = @points[0]
      
    dx = nextPoint.x - point.x
    dy = nextPoint.y - point.y
    @edges.push getEdgeVector dx, dy
    
  # Shift points in closed lines to consolidate same edges at the ends.
  if @isClosed
    while @edges[0] is @edges[@edges.length - 1]
      @points.push @points.shift()
      @edges.push @edges.shift()
      
  # Create edge segments.
  currentEdgeSegment = null
  
  for edge, edgeIndex in @edges
    if edge isnt currentEdgeSegment?.edge
      @edgeSegments.push currentEdgeSegment if currentEdgeSegment?
      
      currentEdgeSegment =
        edge: edge
        count: 0
        startPointIndex: edgeIndex
        endPointIndex: edgeIndex
        clockwise:
          before: null
          after: null
        curveClockwise:
          before: null
          after: null
        
    currentEdgeSegment.count++
    currentEdgeSegment.endPointIndex++
  
  @edgeSegments.push currentEdgeSegment
  
  # Analyze edge segments.
  for edgeSegment, edgeSegmentIndex in @edgeSegments
    edgeSegmentBefore = @getEdgeSegment edgeSegmentIndex - 1
    edgeSegmentAfter = @getEdgeSegment edgeSegmentIndex + 1

    edgeSegment.hasPointSegment =
      before: not edgeSegment.edge.isAxisAligned and not edgeSegmentBefore?.edge.isAxisAligned
      on: edgeSegment.edge.isAxisAligned or edgeSegment.count > 1
      after: not edgeSegment.edge.isAxisAligned and not edgeSegmentAfter?.edge.isAxisAligned
    
    startPointIndex = edgeSegment.startPointIndex
    endPointIndex = edgeSegment.endPointIndex
    
    if edgeSegment.edge.isAxisAligned
      # Axis-aligned edge segments create 1 multiple-point segment.
      edgeSegment.pointSegmentsCount = 1
      edgeSegment.pointSegmentLength = endPointIndex - startPointIndex + 1
      
      # If we're coming from an axis-aligned segment, don't count the same point twice.
      edgeSegment.externalPointSegmentLength = edgeSegment.pointSegmentLength
      edgeSegment.pointSegmentLength-- if edgeSegmentBefore?.edge.isAxisAligned
    
    else
      # Diagonal edge segments create multiple 1-point segments.
      startPointIndex++ unless edgeSegment.hasPointSegment.before
      endPointIndex-- unless edgeSegment.hasPointSegment.after
      
      if startPointIndex > endPointIndex
        startPointIndex = null
        endPointIndex = null
      
      edgeSegment.pointSegmentsCount = if startPointIndex? then endPointIndex - startPointIndex + 1 else 0
      edgeSegment.pointSegmentLength = 1
      edgeSegment.externalPointSegmentLength = 1
      
    edgeSegment.pointSegmentsStartPointIndex = startPointIndex
    edgeSegment.pointSegmentsEndPointIndex = endPointIndex
    edgeSegment.pointsCount = edgeSegment.pointSegmentsCount * edgeSegment.pointSegmentLength
    
    angle = edgeSegment.edge.angle()
    angleAfter = edgeSegmentAfter?.edge.angle()
    
    edgeSegment.clockwise.after = if not edgeSegmentAfter? or edgeSegment.edge is edgeSegmentAfter.edge then null else _.angleDifference(angle, angleAfter) < 0
    edgeSegmentAfter?.clockwise.before = edgeSegment.clockwise.after

    edgeSegment.curveClockwise.after = edgeSegment.clockwise.after
    edgeSegmentAfter?.curveClockwise.before = edgeSegmentAfter.clockwise.before
    
    edgeSegment.corner = after: false
    
  # Detect corners.
  for edgeSegment, edgeSegmentIndex in @edgeSegments
    continue unless edgeSegmentAfter = @getEdgeSegment edgeSegmentIndex + 1
    
    angle = edgeSegment.edge.angle()
    angleAfter = edgeSegmentAfter.edge.angle()
    
    if _.angleDistance(angle, angleAfter) > 1
      edgeSegment.corner.after = true
      
    else
      minPointLength = edgeSegmentMinPointLengthForCorner
      edgeSegmentIsLong = edgeSegment.pointSegmentLength >= minPointLength or edgeSegment.pointSegmentsCount >= minPointLength
      edgeSegmentAfterIsLong = edgeSegmentAfter.pointSegmentLength >= minPointLength or edgeSegmentAfter.pointSegmentsCount >= minPointLength
      edgeSegment.corner.after = edgeSegmentIsLong and edgeSegmentAfterIsLong
  
  # Detect side-step segments.
  for edgeSegment, edgeSegmentIndex in @edgeSegments when edgeSegment.edge.isAxisAligned
    continue unless edgeSegmentAfter = @getEdgeSegment edgeSegmentIndex + 1
    continue unless edgeSegmentAfter.count is 1
    
    continue unless edgeSegmentAfter2 = @getEdgeSegment edgeSegmentIndex + 2
    continue unless edgeSegmentAfter2.edge is edgeSegment.edge
    
    edgeSegmentAfter.isSideStep = true
    
    # We have two neighboring point segments in the same direction so the curvature direction is dependent on the change of repetition count.
    if edgeSegmentAfter2.count is edgeSegment.count
      # This is a straight segment so no direction can be determined.
      edgeSegment.curveClockwise.after = null

    else if edgeSegmentAfter2.count > edgeSegment.count
      # The repeating count is increasing so the curve curves in the direction towards the after segment.
      edgeSegment.curveClockwise.after = edgeSegmentAfter2.curveClockwise.before
    
    edgeSegmentAfter.curveClockwise.before = edgeSegment.curveClockwise.after
    edgeSegmentAfter.curveClockwise.after = edgeSegment.curveClockwise.after
    edgeSegmentAfter2.curveClockwise.before = edgeSegment.curveClockwise.after
    
    # Side-step segments can't be corners.
    edgeSegment.corner.after = false
    edgeSegmentAfter.corner.after = false

  # Detect straight lines.
  lastStraightLineStartSegmentIndex = null
  lastStraightLineEndSegmentIndex = null
  
  addStraightLinePart = (startSegmentIndex, endSegmentIndex) =>
    # Don't add a straight line that is already contained within the last straight line.
    return if lastStraightLineStartSegmentIndex? and startSegmentIndex >= lastStraightLineStartSegmentIndex and endSegmentIndex <= lastStraightLineEndSegmentIndex
    
    lastStraightLineStartSegmentIndex = startSegmentIndex
    lastStraightLineEndSegmentIndex = endSegmentIndex
    
    straightLine = new PAE.Line.Part.StraightLine @, startSegmentIndex, endSegmentIndex
    @potentialParts.push straightLine
    @potentialStraightLineParts.push straightLine

  for startSegmentIndex in [0...@edgeSegments.length]
    startEdgeSegment = @edgeSegments[startSegmentIndex]
    
    # Start on edge segments that introduce point segments.
    continue unless startEdgeSegment.pointsCount

    sideEdgeClockwise = startEdgeSegment.clockwise.after

    # Straight lines are composed of equally sized segments, but allow for 1 count difference for intermediary lines,
    # so we need two possible main counts. Further, the starting and ending segment can be of any length shorter than
    # the main count.
    mainPointsCount1 = null
    mainPointsCount2 = null

    endSegmentIndex = startSegmentIndex
    
    loop
      edgeSegment = @getEdgeSegment endSegmentIndex

      # Stop if we reached a corner.
      break if edgeSegment.corner.after
      
      # Find a side-step segment.
      break unless nextEdgeSegment = @getEdgeSegment endSegmentIndex + 1
      unless nextEdgeSegment.count is 1
        # If we've started on a side-step segment, we can move on.
        if endSegmentIndex is startSegmentIndex and edgeSegment.count is 1
          endSegmentIndex++
          
          # Pretend as we're starting fresh from the next segment.
          startEdgeSegment = @getEdgeSegment endSegmentIndex
          sideEdgeClockwise = not startEdgeSegment.clockwise.before
          
          break unless startEdgeSegment.clockwise.after is sideEdgeClockwise
          
          continue
        
        # The final segment can be a longer if it's not really a side-step as we were only on 1-length segments so far.
        endSegmentIndex++ if mainPointsCount1 is 1 and nextEdgeSegment.pointsCount is 2
        
        break

      # Prevent diagonal to diagonal segments (most likely 90 degrees on a 45 degree diagonal).
      break unless startEdgeSegment.edge.isAxisAligned or nextEdgeSegment.edge.isAxisAligned

      # See if we have a next segment going into the right direction after this.
      endStraightLine = false
      endStraightLine = true unless secondNextEdgeSegment = @getEdgeSegment endSegmentIndex + 2
      endStraightLine = true unless secondNextEdgeSegment?.edge is startEdgeSegment.edge
      
      if endStraightLine
        # Include the final side-step segment if it provides a point.
        endSegmentIndex++ if nextEdgeSegment.pointSegmentsCount
        
        break
      
      # Determine how long the main (middle) parts of the diagonal are.
      determineExtraCount = false

      unless mainPointsCount1
        # We're determining the initial count.
        if secondNextEdgeSegment.pointsCount > startEdgeSegment.pointsCount
          # The first element is shorter so we can consider it being the ending part.
          mainPointsCount1 = secondNextEdgeSegment.pointsCount
          
        else
          mainPointsCount1 = startEdgeSegment.pointsCount
          determineExtraCount = true
          
      else unless mainPointsCount2
        determineExtraCount = true
        
      else unless secondNextEdgeSegment.pointsCount in [mainPointsCount1, mainPointsCount2]
        endStraightLine = true
        
      if determineExtraCount
        unless secondNextEdgeSegment.pointsCount is mainPointsCount1
          # The extra count can only differ by 1 from main count.
          if Math.abs(mainPointsCount1 - secondNextEdgeSegment.pointsCount) is 1
            mainPointsCount2 = secondNextEdgeSegment.pointsCount
          
          else
            endStraightLine = true
        
      if endStraightLine
        # This segment is too much different than the main segment, but it could be the final part if it's shorter.
        if secondNextEdgeSegment.pointsCount < mainPointsCount1
          # Allow this segment to be the end of the straight line.
          endSegmentIndex += 2
          
        break
      
      endSegmentIndex += 2
      
      break unless secondNextEdgeSegment.clockwise.after is sideEdgeClockwise
      
    addStraightLinePart startSegmentIndex, endSegmentIndex
  
  # Detect curves.
  addCurvePart = (startSegmentIndex, endSegmentIndex) =>
    if endSegmentIndex >= startSegmentIndex + @edgeSegments.length
      endSegmentIndex = startSegmentIndex + @edgeSegments.length - 1
      isClosed = true
      
    else
      isClosed = false
      
      # Don't add a curve that is already contained within another part.
      for part in @potentialParts
        return if startSegmentIndex >= part.startSegmentIndex and endSegmentIndex <= part.endSegmentIndex
    
    curve = new PAE.Line.Part.Curve @, startSegmentIndex, endSegmentIndex, null, null, isClosed
    @potentialParts.push curve
    @potentialCurveParts.push curve

    curve
    
  for startSegmentIndex in [0...@edgeSegments.length]
    startEdgeSegment = @edgeSegments[startSegmentIndex]
    edgeSegment = startEdgeSegment
    
    # Start on edge segments that introduce point segments.
    continue unless edgeSegment.pointSegmentsCount
    clockwise = edgeSegment.curveClockwise.after
    endSegmentIndex = startSegmentIndex
    
    # Keep expanding until the turn of direction.
    while clockwise is edgeSegment.curveClockwise.after or not clockwise? or not edgeSegment.curveClockwise.after?
      clockwise ?= edgeSegment.curveClockwise.after

      # Stop if we reached a corner.
      break if edgeSegment.corner.after
      
      # Stop at the end, otherwise continue to next segment.
      break unless edgeSegment = @getEdgeSegment endSegmentIndex + 1
      endSegmentIndex++

      break if edgeSegment is startEdgeSegment
      
    continue unless clockwise?

    curve = addCurvePart startSegmentIndex, endSegmentIndex
    
    # No need to keep going if we found a closed curve.
    break if curve?.isClosed
    
  # Pick the most likely parts for each point.
  potentialCurvePart.calculatePointConfidence() for potentialCurvePart in @potentialCurveParts
  
  for point, pointIndex in @points
    @pointPartIsCurve[pointIndex] = false
    
    for potentialCurvePart in @potentialCurveParts
      if potentialCurvePart.pointConfidences[pointIndex]
        @pointPartIsCurve[pointIndex] = true
        break
    
  # Create final line parts.
  if @isClosed
    # For closed lines, first determine where the first edge between a curve and a straight line is.
    firstCurveStraightLineEdgePointIndex = null
    
    for pointIndex in [0...@points.length]
      unless @isPointPartCurve(pointIndex) is @isPointPartCurve(pointIndex + 1)
        firstCurveStraightLineEdgePointIndex = pointIndex + 1
        break
        
    # If we didn't find an edge at all it means all parts are the same.
    if firstCurveStraightLineEdgePointIndex is null
      if @isPointPartCurve 0
        # For curves, we can create a closed one.
        @parts.push new PAE.Line.Part.Curve @, 0, @edgeSegments.length - 1, 0, @points.length - 1, true
        return
    
      else
        # Straight polygons can be created from the start forward.
        firstCurveStraightLineEdgePointIndex ?= 0
    
  else
    # For open lines, we can simply start at the beginning since there will not be any wrap around.
    firstCurveStraightLineEdgePointIndex = 0
    
  pointPartIsCurve = null
  startSegmentIndex = null
  startPointIndex = null
  normalizedStartPointIndex = null
  
  segmentIndex = 0
  edgeSegment = @getEdgeSegment 0
  
  startRangePointIndex = firstCurveStraightLineEdgePointIndex
  endRangePointIndex = firstCurveStraightLineEdgePointIndex + @points.length - 1
  
  for pointIndex in [startRangePointIndex..endRangePointIndex]
    normalizedPointIndex = pointIndex % @points.length
    
    while normalizedPointIndex > edgeSegment.endPointIndex or normalizedPointIndex < edgeSegment.startPointIndex
      segmentIndex++
      edgeSegment = @getEdgeSegment segmentIndex
    
    startSegmentIndex ?= segmentIndex
    startPointIndex ?= pointIndex
    normalizedStartPointIndex ?= normalizedPointIndex
    pointPartIsCurve ?= @isPointPartCurve pointIndex
    
    # Keep expanding if we'll be on the same type of a part.
    continue if pointIndex isnt endRangePointIndex and @isPointPartCurve(pointIndex + 1) is pointPartIsCurve
    
    if pointPartIsCurve
      @parts.push new PAE.Line.Part.Curve @, startSegmentIndex, segmentIndex, normalizedStartPointIndex, normalizedPointIndex, false
      
    else
      # Find which straight line parts overlay the segment.
      potentialStraightLineParts = (part for part in @potentialStraightLineParts when part.overlaysPointRange normalizedStartPointIndex, normalizedPointIndex)
      
      potentialStraightLineSegmentRanges = []
      
      # Remove segments that aren't in the straight-line window.
      for part, partIndex in potentialStraightLineParts
        startPointIndex = _.modulo Math.max(part.startPointIndex, normalizedStartPointIndex - 1), @points.length
        endPointIndex = _.modulo Math.min(part.endPointIndex, normalizedPointIndex + 1), @points.length
        
        start = part.startSegmentIndex
        end = part.endSegmentIndex
        
        start++ while not @_edgeSegmentOverlaysPointRange start, startPointIndex, endPointIndex
        end-- while not @_edgeSegmentOverlaysPointRange end, startPointIndex, endPointIndex
        
        potentialStraightLineSegmentRanges.push {start, end}
      
      # Remove lines that are included in other lines.
      segmentRangeIndex = 0
      
      while segmentRangeIndex < potentialStraightLineSegmentRanges.length
        start = potentialStraightLineSegmentRanges[segmentRangeIndex].start
        end = potentialStraightLineSegmentRanges[segmentRangeIndex].end
        
        remove = false
        for segmentRange, otherSegmentRangeIndex in potentialStraightLineSegmentRanges when otherSegmentRangeIndex isnt segmentRangeIndex
          if start >= segmentRange.start and end <= segmentRange.end
            remove = true
            break
            
        if remove
          potentialStraightLineSegmentRanges.splice segmentRangeIndex, 1
          
        else
          segmentRangeIndex++
          
      # Rotate the parts until the first one is the one starting at this starting segment.
      if @isClosed
        normalizedStartSegmentIndex = _.modulo startSegmentIndex, @edgeSegments.length
        
        while potentialStraightLineSegmentRanges[0].end < normalizedStartSegmentIndex
          potentialStraightLineSegmentRanges.push potentialStraightLineSegmentRanges.shift()
          
      for segmentRange in potentialStraightLineSegmentRanges
        @parts.push new PAE.Line.Part.StraightLine @, segmentRange.start, segmentRange.end
      
    startSegmentIndex = null
    startPointIndex = null
    normalizedStartPointIndex = null
    pointPartIsCurve = null
    
  for part, partIndex in @parts
    part.setNeighbors @getPart(partIndex - 1), @getPart(partIndex + 1)

PAE.Line::_edgeSegmentOverlaysPointRange = (segmentIndex, startPointIndex, endPointIndex) ->
  segment = @getEdgeSegment segmentIndex
  return false unless segment.pointSegmentsCount

  pointCount = @points.length
  startPointIndex = startPointIndex % pointCount
  endPointIndex = endPointIndex % pointCount
  
  if endPointIndex >= startPointIndex
    startPointIndex <= segment.endPointIndex and endPointIndex >= segment.startPointIndex
  
  else
    startPointIndex <= segment.endPointIndex or endPointIndex >= segment.startPointIndex
