AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

edgeVectors = {}

getEdgeVector = (x, y) ->
  edgeVectors[x] ?= {}
  
  unless edgeVectors[x][y]
    edgeVectors[x][y] = new THREE.Vector2 x, y
    edgeVectors[x][y].isAxisAligned = x is 0 or y is 0
    
  edgeVectors[x][y]
  
maxPointDistanceFromLine = Math.sqrt 2

_testLine = new THREE.Line3
_testPosition = new THREE.Vector3
_projectedPosition = new THREE.Vector3

class PAG.Line
  constructor: (@grading) ->
    @id = Random.id()
    
    @pixels = []
    @points = []
    @core = null
    
    @isClosed = false

    @edges = []
    @edgeSegments = []
    @straightLineParts = []
    @curveParts = []
    
  destroy: ->
    pixel.unassignLine @ for pixel in @pixels
    point.unassignLine @ for point in @points
    @core?.unassignOutline @
  
  assignPoint: (point, end = true) ->
    throw new AE.ArgumentException "The point is already assigned to this line.", point, @ if point in @points

    if end
      @points.push point
    
    else
      @points.unshift point
  
  assignCore: (core) ->
    throw new AE.ArgumentException "A core is already assigned to this line.", core, @ if @core
    @core = core
    
  unassignPoint: (point) ->
    throw new AE.ArgumentException "The point is not assigned to this line.", point, @ unless point in @points
    _.pull @points, point
  
  unassignCore: (core) ->
    throw new AE.ArgumentException "The core is not assigned to this line.", core, @ unless core is @core
    @core = null

  addPixel: (pixel) ->
    @pixels.push pixel
    pixel.assignLine @
  
  fillFromPoints: (pointA, pointB) ->
    # Start the line with these two points.
    @_addExpansionPoint pointA
    @_addExpansionPoint pointB

    # Now expand in both directions as far as you can.
    @_expandLine pointA, pointB, (point) => @_addExpansionPoint point
    @_expandLine pointB, pointA, (point) => @_addExpansionPoint point, false
  
  _expandLine: (previousPoint, currentPoint, operation) ->
    loop
      # Stop when we get to end segments or junctions.
      return unless currentPoint.neighbors.length is 2
      
      nextPoint = if currentPoint.neighbors[0] is previousPoint then currentPoint.neighbors[1] else currentPoint.neighbors[0]

      # Stop if we run into our own start/end, which makes for a closed line.
      if nextPoint is @points[0] or nextPoint is @points[@points.length - 1]
        @isClosed = true
        return
      
      operation nextPoint
      
      previousPoint = currentPoint
      currentPoint = nextPoint
  
  _addExpansionPoint: (point, end) ->
    @assignPoint point, end
    point.assignLine @
    
    for pixel in point.pixels
      @addPixel pixel unless pixel in @pixels
  
  addOutlinePoints: ->
    # For outlines, we expect the line already has all the pixels assigned and all the points already
    # have this line assigned to them, we just need to add the points in the correct order.
    startingPoint = _.find @pixels[0].points, (point) => @ in point.lines
    @points.push startingPoint

    previousPoint = startingPoint
    currentPoint = _.find startingPoint.neighbors, (point) => @ in point.lines
    @points.push currentPoint
    
    @isClosed = true
    
    loop
      nextPoint = _.find currentPoint.neighbors, (point) => @ in point.lines and point isnt previousPoint
      
      return if nextPoint is startingPoint
      
      @points.push nextPoint
      
      previousPoint = currentPoint
      currentPoint = nextPoint
      
  classifyLineParts: ->
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
    
    getEdge = (index) => if @isClosed then @edges[_.modulo index, @edges.length] else @edges[index]
    getEdgeSegment = (index) => if @isClosed then @edgeSegments[_.modulo index, @edgeSegments.length] else @edgeSegments[index]
    getPoint = (index) => if @isClosed then @points[_.modulo index, @points.length] else @points[index]
    
    # Analyze edge segments.
    for edgeSegment, edgeSegmentIndex in @edgeSegments
      edgeSegmentBefore = getEdgeSegment edgeSegmentIndex - 1
      edgeSegmentAfter = getEdgeSegment edgeSegmentIndex + 1

      edgeSegment.hasPointSegment =
        before: not edgeSegment.edge.isAxisAligned and not edgeSegmentBefore?.edge.isAxisAligned
        on: edgeSegment.edge.isAxisAligned or edgeSegment.count > 1
        after: not edgeSegment.edge.isAxisAligned and not edgeSegmentAfter?.edge.isAxisAligned
        
      edgeSegment.clockwise.after = if not edgeSegmentAfter? or edgeSegment.edge is edgeSegmentAfter.edge then null else _.angleDifference(edgeSegment.edge.angle(), edgeSegmentAfter.edge.angle()) < 0
      edgeSegmentAfter?.clockwise.before = edgeSegment.clockwise.after

      edgeSegment.curveClockwise.after = edgeSegment.clockwise.after
      edgeSegmentAfter?.curveClockwise.before = edgeSegmentAfter.clockwise.before
      
    for edgeSegment, edgeSegmentIndex in @edgeSegments when edgeSegment.edge.isAxisAligned
      continue unless edgeSegmentAfter = getEdgeSegment edgeSegmentIndex + 1
      continue unless edgeSegmentAfter.count is 1
      
      continue unless edgeSegmentAfter2 = getEdgeSegment edgeSegmentIndex + 2
      continue unless edgeSegmentAfter2.edge is edgeSegment.edge
      
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

    # Detect straight lines.
    lastStraightLineStartSegmentIndex = null
    lastStraightEndSegmentIndex = null
    
    addStraightLinePart = (startSegmentIndex, endSegmentIndex) =>
      # Don't add diagonals that are already contained within the last diagonal.
      return if lastStraightLineStartSegmentIndex? and startSegmentIndex >= lastStraightLineStartSegmentIndex and endSegmentIndex <= lastStraightEndSegmentIndex
      
      lastStraightLineStartSegmentIndex = startSegmentIndex
      lastStraightEndSegmentIndex = endSegmentIndex
      
      @straightLineParts.push
        startPoint: getPoint getEdgeSegment(startSegmentIndex).startPointIndex
        endPoint: getPoint getEdgeSegment(endSegmentIndex).endPointIndex
    
    for startSegmentIndex in [0...@edgeSegments.length]
      mainEdgeSegment = @edgeSegments[startSegmentIndex]

      sideEdgeClockwise = mainEdgeSegment.clockwise.after

      mainCount = mainEdgeSegment.count
      extraCount = mainCount

      endSegmentIndex = startSegmentIndex
      
      loop
        break unless nextEdgeSegment = getEdgeSegment endSegmentIndex + 1
        break unless nextEdgeSegment.count is 1
        
        break unless nextEdgeSegment = getEdgeSegment endSegmentIndex + 2
        break unless nextEdgeSegment.edge is mainEdgeSegment.edge
        
        unless extraCount isnt mainCount or nextEdgeSegment.count is mainCount
          extraCount = nextEdgeSegment.count
          break unless Math.abs(mainCount - extraCount) is 1
          
        break unless nextEdgeSegment.count in [mainCount, extraCount]
        
        endSegmentIndex += 2
        
        break unless nextEdgeSegment.clockwise.after is sideEdgeClockwise
      
      addStraightLinePart startSegmentIndex, endSegmentIndex
    
    # Detect curves
    lastCurveStartSegmentIndex = null
    lastCurveEndSegmentIndex = null
    
    addCurvePart = (startSegmentIndex, endSegmentIndex) =>
      if endSegmentIndex >= startSegmentIndex + @edgeSegments.length
        endSegmentIndex = startSegmentIndex + @edgeSegments.length - 1
        isClosed = true
        
      else
        isClosed = false
        
      # Don't add curves that are already contained within the last curve.
      return if lastCurveStartSegmentIndex? and startSegmentIndex >= lastCurveStartSegmentIndex and endSegmentIndex <= lastCurveEndSegmentIndex
      
      lastCurveStartSegmentIndex = startSegmentIndex
      lastCurveEndSegmentIndex = endSegmentIndex
      
      curve =
        segments: []
        points: []
        isClosed: isClosed
      
      segmentParameter = 0.5
      
      for segmentIndex in [startSegmentIndex..endSegmentIndex]
        segment = getEdgeSegment segmentIndex
        curve.segments.push segment
        
        # Exclude side-step segments from generating curve points, except at end points.
        continue unless segment.hasPointSegment.before or segment.hasPointSegment.on or segment.hasPointSegment.after
        
        startPoint = getPoint segment.startPointIndex
        endPoint = getPoint segment.endPointIndex
        
        unless isClosed
          segmentParameter = switch segmentIndex
            when startSegmentIndex then 0
            when endSegmentIndex then 1
            else 0.5
        
        curve.points.push
          x: THREE.MathUtils.lerp startPoint.x, endPoint.x, segmentParameter
          y: THREE.MathUtils.lerp startPoint.y, endPoint.y, segmentParameter
          
      if isClosed and (curve.points[0].x isnt curve.points[curve.points.length - 1].x or curve.points[0].y isnt curve.points[curve.points.length - 1].y)
        curve.points.push curve.points[0]
        
      if curve.points.length is 2
        startPoint = getPoint getEdgeSegment(startSegmentIndex).endPointIndex
        endPoint = getPoint getEdgeSegment(endSegmentIndex).startPointIndex
        
        curve.points.splice 1, 0,
          x: THREE.MathUtils.lerp startPoint.x, endPoint.x, 0.5
          y: THREE.MathUtils.lerp startPoint.y, endPoint.y, 0.5
      
      @curveParts.push curve
      
    for startSegmentIndex in [0...@edgeSegments.length]
      startEdgeSegment = @edgeSegments[startSegmentIndex]
      edgeSegment = startEdgeSegment
      
      # Start on edge segments that introduce point segments.
      continue unless edgeSegment.hasPointSegment.before or edgeSegment.hasPointSegment.on
      clockwise = edgeSegment.curveClockwise.after
      endSegmentIndex = startSegmentIndex
      
      # Keep expanding until the turn of direction.
      while clockwise is edgeSegment.curveClockwise.after or not clockwise? or not edgeSegment.curveClockwise.after?
        clockwise ?= edgeSegment.curveClockwise.after

        break unless edgeSegment = getEdgeSegment endSegmentIndex + 1
        endSegmentIndex++

        break if edgeSegment is startEdgeSegment
        
      continue unless clockwise?

      addCurvePart startSegmentIndex, endSegmentIndex
      
      # No need to keep going if we found a closed curve.
      break if _.last(@curveParts).isClosed
