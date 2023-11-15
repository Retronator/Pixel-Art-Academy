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

class PAG.Line
  constructor: (@grading) ->
    @id = Random.id()
    
    @pixels = []
    @points = []
    @core = null
    
    @isClosed = false

    @edges = []
    @edgeSegments = []

    @potentialParts = []
    @pointPotentialParts = []
    
    @parts = []
    
  destroy: ->
    pixel.unassignLine @ for pixel in @pixels
    point.unassignLine @ for point in @points
    @core?.unassignOutline @
    
  getEdgeSegment: (index) ->
    if @isClosed then @edgeSegments[_.modulo index, @edgeSegments.length] else @edgeSegments[index]

  getPoint: (index) ->
    if @isClosed then @points[_.modulo index, @points.length] else @points[index]
  
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
    
    # Analyze edge segments.
    for edgeSegment, edgeSegmentIndex in @edgeSegments
      edgeSegment.displayStartPointIndex = edgeSegment.startPointIndex
      edgeSegment.displayEndPointIndex = edgeSegment.endPointIndex
    
      edgeSegmentBefore = @getEdgeSegment edgeSegmentIndex - 1
      edgeSegmentAfter = @getEdgeSegment edgeSegmentIndex + 1

      edgeSegment.hasPointSegment =
        before: not edgeSegment.edge.isAxisAligned and not edgeSegmentBefore?.edge.isAxisAligned
        on: edgeSegment.edge.isAxisAligned or edgeSegment.count > 1
        after: not edgeSegment.edge.isAxisAligned and not edgeSegmentAfter?.edge.isAxisAligned
      
      if edgeSegment.edge.isAxisAligned
        # Axis aligned edge segments create 1 multiple-point segment.
        edgeSegment.pointSegmentsCount = 1
        edgeSegment.pointSegmentLength = if edgeSegment.startPointIndex? then edgeSegment.endPointIndex - edgeSegment.startPointIndex + 1 else 0
        
      else
        edgeSegment.startPointIndex++ unless edgeSegment.hasPointSegment.before
        edgeSegment.endPointIndex-- unless edgeSegment.hasPointSegment.after
        
        if edgeSegment.startPointIndex > edgeSegment.endPointIndex
          edgeSegment.startPointIndex = null
          edgeSegment.endPointIndex = null
          
        # Diagonal edge segments create multiple 1-point segments.
        edgeSegment.pointSegmentsCount = if edgeSegment.startPointIndex? then edgeSegment.endPointIndex - edgeSegment.startPointIndex + 1 else 0
        edgeSegment.pointSegmentLength = 1
      
      edgeSegment.clockwise.after = if not edgeSegmentAfter? or edgeSegment.edge is edgeSegmentAfter.edge then null else _.angleDifference(edgeSegment.edge.angle(), edgeSegmentAfter.edge.angle()) < 0
      edgeSegmentAfter?.clockwise.before = edgeSegment.clockwise.after

      edgeSegment.curveClockwise.after = edgeSegment.clockwise.after
      edgeSegmentAfter?.curveClockwise.before = edgeSegmentAfter.clockwise.before
      
    for edgeSegment, edgeSegmentIndex in @edgeSegments when edgeSegment.edge.isAxisAligned
      continue unless edgeSegmentAfter = @getEdgeSegment edgeSegmentIndex + 1
      continue unless edgeSegmentAfter.count is 1
      
      continue unless edgeSegmentAfter2 = @getEdgeSegment edgeSegmentIndex + 2
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
    lastStraightLineEndSegmentIndex = null
    
    addStraightLinePart = (startSegmentIndex, endSegmentIndex, averageSegmentCount) =>
      # Don't add a straight line that is already contained within the last straight line.
      return if lastStraightLineStartSegmentIndex? and startSegmentIndex >= lastStraightLineStartSegmentIndex and endSegmentIndex <= lastStraightLineEndSegmentIndex
      
      lastStraightLineStartSegmentIndex = startSegmentIndex
      lastStraightLineEndSegmentIndex = endSegmentIndex
      
      @potentialParts.push new PAG.Line.Part.StraightLine @, startSegmentIndex, endSegmentIndex, null, null, averageSegmentCount

    for startSegmentIndex in [0...@edgeSegments.length]
      startEdgeSegment = @edgeSegments[startSegmentIndex]
      
      # Start on edge segments that introduce point segments.
      continue unless startEdgeSegment.pointSegmentsCount

      sideEdgeClockwise = startEdgeSegment.clockwise.after

      mainCount = null
      extraCount = null

      endSegmentIndex = startSegmentIndex
      
      loop
        break unless nextEdgeSegment = @getEdgeSegment endSegmentIndex + 1
        break unless nextEdgeSegment.count is 1
        break unless startEdgeSegment.edge.isAxisAligned or nextEdgeSegment.edge.isAxisAligned
        
        unless secondNextEdgeSegment = @getEdgeSegment endSegmentIndex + 2
          # Include the final side-step segment if it provides a point.
          endSegmentIndex++ if nextEdgeSegment.pointSegmentsCount
          
          break
        
        break unless secondNextEdgeSegment.edge is startEdgeSegment.edge

        endStraightLine = false
        determineExtraCount = false

        unless mainCount
          # We're determining the initial count.
          if secondNextEdgeSegment.count > startEdgeSegment.count
            # The first element is shorter so we can consider it being the ending part.
            mainCount = secondNextEdgeSegment.count
            
          else
            mainCount = startEdgeSegment.count
            determineExtraCount = true
            
        else unless extraCount
          determineExtraCount = true
          
        else unless secondNextEdgeSegment.count in [mainCount, extraCount]
          endStraightLine = true
          
        if determineExtraCount
          unless secondNextEdgeSegment.count is mainCount
            # The extra count can only differ by 1 from main count.
            if Math.abs(mainCount - secondNextEdgeSegment.count) is 1
              extraCount = secondNextEdgeSegment.count
            
            else
              endStraightLine = true
          
        if endStraightLine
          # This segment is too much different than the main segment, but it could be the final part if it's shorter.
          if secondNextEdgeSegment.count < mainCount
            # Allow this segment to be the end of the straight line.
            endSegmentIndex += 2
            
          break
        
        endSegmentIndex += 2
        
        break unless secondNextEdgeSegment.clockwise.after is sideEdgeClockwise
        
      mainCount ?= startEdgeSegment.count
      extraCount ?= mainCount
      
      addStraightLinePart startSegmentIndex, endSegmentIndex, (mainCount + extraCount) / 2
    
    # Detect curves
    lastCurveStartSegmentIndex = null
    lastCurveEndSegmentIndex = null
    
    addCurvePart = (startSegmentIndex, endSegmentIndex) =>
      if endSegmentIndex >= startSegmentIndex + @edgeSegments.length
        endSegmentIndex = startSegmentIndex + @edgeSegments.length - 1
        isClosed = true
        
      else
        isClosed = false
        
      # Don't add a curve that is already contained within the last curve.
      return if lastCurveStartSegmentIndex? and startSegmentIndex >= lastCurveStartSegmentIndex and endSegmentIndex <= lastCurveEndSegmentIndex
      
      lastCurveStartSegmentIndex = startSegmentIndex
      lastCurveEndSegmentIndex = endSegmentIndex
      
      curve = new PAG.Line.Part.Curve @, startSegmentIndex, endSegmentIndex, null, null, isClosed
      @potentialParts.push curve

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

        break unless edgeSegment = @getEdgeSegment endSegmentIndex + 1
        endSegmentIndex++

        break if edgeSegment is startEdgeSegment
        
      continue unless clockwise?

      curve = addCurvePart startSegmentIndex, endSegmentIndex
      
      # No need to keep going if we found a closed curve.
      break if curve?.isClosed
      
    # Pick the most likely parts for each point.
    potentialLinePart.calculatePointConfidence() for potentialLinePart in @potentialParts
    
    for point, pointIndex in @points
      maxWeightedConfidence = Number.NEGATIVE_INFINITY
      mostConfidentPart = null
      
      for potentialLinePart in @potentialParts
        confidence = potentialLinePart.pointConfidences[pointIndex]
        continue unless confidence?
        
        weightedConfidence = confidence * Math.min 10, potentialLinePart.points.length
        
        if weightedConfidence > maxWeightedConfidence
          maxWeightedConfidence = weightedConfidence
          mostConfidentPart = potentialLinePart
      
      @pointPotentialParts.push mostConfidentPart
      
    # Create final line parts.
    startPointIndex = 0
    
    for point, pointIndex in @points
      unless potentialPart = @pointPotentialParts[pointIndex]
        startPointIndex = pointIndex + 1
        continue

      nextPotentialPart = @pointPotentialParts[pointIndex + 1]
      continue if nextPotentialPart is potentialPart
      
      endPointIndex = pointIndex
    
      # Find which edge segments include starting/ending point indexes.
      startSegmentIndex = null
      endSegmentIndex = null
      
      for segmentIndex in [potentialPart.startSegmentIndex..potentialPart.endSegmentIndex]
        segment = @getEdgeSegment segmentIndex
        
        startSegmentIndex ?= segmentIndex if segment.startPointIndex <= startPointIndex <= segment.endPointIndex
        endSegmentIndex = segmentIndex if segment.startPointIndex <= endPointIndex <= segment.endPointIndex
        
      @parts.push new potentialPart.constructor @, startSegmentIndex, endSegmentIndex, startPointIndex, endPointIndex, potentialPart.isClosed
      
      startPointIndex = endPointIndex + 1
