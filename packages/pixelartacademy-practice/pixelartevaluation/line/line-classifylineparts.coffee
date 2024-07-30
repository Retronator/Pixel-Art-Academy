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
        corner:
          before: false
          after: false
        
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

      # Store how long the segment is if we're not making it shorter because of pixel sharing.
      edgeSegment.externalPointSegmentLength = edgeSegment.pointSegmentLength
      
      # If we're coming from an axis-aligned segment, don't count the same point twice.
      # We either need to let the previous segment count for our starting pixel or us take it away from them.
      if edgeSegmentBefore?.edge.isAxisAligned
        if edgeSegmentBefore.pointSegmentLength is 1
          # Capture the single point of side-step segments.
          edgeSegmentBefore.pointSegmentsCount = 0
          edgeSegmentBefore.hasPointSegment.on = false
          
        else
          edgeSegment.pointSegmentLength--
          startPointIndex++
    
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

    edgeSegmentAfter.corner.before = edgeSegment.corner.after
    
  unless @isClosed
    _.first(@edgeSegments).corner.before = true
    _.last(@edgeSegments).corner.after = true
  
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
    edgeSegmentAfter.corner.before = false
    edgeSegmentAfter.corner.after = false
    edgeSegmentAfter2.corner.before = false
    
  # Create line parts.
  @_detectStraightLineParts()
  @_detectCurveParts()
  @_createParts()
  
  # Analyze curvature.
  @_analyzeCurvature()
