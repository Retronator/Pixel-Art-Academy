AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

edgeVectors = {}

getEdgeVector = (x, y) ->
  edgeVectors[x] ?= {}
  edgeVectors[x][y] ?= new THREE.Vector2 x, y
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
    @diagonals = []
    @curves = []
    
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
      
  classifyLineSegments: ->
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
          
      currentEdgeSegment.count++
      currentEdgeSegment.endPointIndex++
    
    @edgeSegments.push currentEdgeSegment
    
    # Detect diagonals.
    getEdge = (index) => if @isClosed then @edges[_.modulo index, @edges.length] else @edges[index]
    getEdgeSegment = (index) => if @isClosed then @edgeSegments[_.modulo index, @edgeSegments.length] else @edgeSegments[index]
    getPoint = (index) => if @isClosed then @points[_.modulo index, @points.length] else @points[index]

    addDiagonal = (startIndex, endIndex) =>
      startPoint = getPoint startIndex
      endPoint = getPoint endIndex
      
      @diagonals.push
        startPoint: startPoint
        endPoint: endPoint
        
    edgeSegmentCovered = (false for edgeSegment in @edgeSegments)
    
    # Cover edge segments from biggest to smallest.
    loop
      largestSegmentIndex = null
      largestSegmentCount = 0
      
      for edgeSegment, index in @edgeSegments when not edgeSegmentCovered[index]
        if edgeSegment.count > largestSegmentCount
          largestSegmentIndex = index
          largestSegmentCount = edgeSegment.count
      
      break unless largestSegmentIndex?
      largestSegment = @edgeSegments[largestSegmentIndex]
      edgeSegmentCovered[largestSegmentIndex] = true
      
      diagonalSegmentStartIndex = largestSegmentIndex
      diagonalSegmentEndIndex = largestSegmentIndex
      
      # Diagonal edges are by default diagonal.
      diagonalFound = largestSegment.edge.x isnt 0 and largestSegment.edge.y isnt 0
      
      firstNextSegment = null
      
      expandSegment = (index, indexDirection) =>
        loop
          break if edgeSegmentCovered[index + indexDirection] or edgeSegmentCovered[index + 2 * indexDirection]
          
          break unless nextSegment = getEdgeSegment index + indexDirection
          break if nextSegment.count > 1
          
          firstNextSegment ?= nextSegment
          
          break if nextSegment.edge.x and nextSegment.edge.x is -firstNextSegment.edge.x
          break if nextSegment.edge.y and nextSegment.edge.y is -firstNextSegment.edge.y
          
          break unless nextRepeatingSegment = getEdgeSegment index + 2 * indexDirection
          break if nextRepeatingSegment.edge isnt largestSegment.edge
          break if nextRepeatingSegment.count > largestSegment.count
          
          index += 2 * indexDirection
          diagonalFound = true
          break if nextRepeatingSegment.count < largestSegment.count - 1
          
        index

      diagonalSegmentEndIndex = expandSegment diagonalSegmentEndIndex, 1
      diagonalSegmentStartIndex = expandSegment diagonalSegmentStartIndex, -1
      
      break unless diagonalFound
      
      edgeSegmentCovered[i] = true for i in [diagonalSegmentStartIndex..diagonalSegmentEndIndex]
      
      addDiagonal getEdgeSegment(diagonalSegmentStartIndex).startPointIndex, getEdgeSegment(diagonalSegmentEndIndex).endPointIndex
      
    # Detect curves
    lastCurveStartSegmentIndex = null
    lastCurveEndSegmentIndex = null
    
    addCurve = (startSegmentIndex, endSegmentIndex, segmentsInfo) =>
      getEdgeSegment(startSegmentIndex).startPointIndex
      getEdgeSegment(endSegmentIndex).endPointIndex
      
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
      
      for segmentInfo in segmentsInfo
        segmentIndex = segmentInfo.index
        segment = getEdgeSegment segmentIndex
        curve.segments.push segment
        
        # Exclude side-step segments from generating curve points, except at end points.
        isEnd = segmentIndex is startSegmentIndex or segmentIndex is endSegmentIndex
        continue if segmentInfo.isSideStep and not (isEnd and not isClosed)
        
        startPoint = getPoint segment.startPointIndex
        endPoint = getPoint segment.endPointIndex
        
        segmentParameter = (segmentIndex - startSegmentIndex) / (endSegmentIndex - startSegmentIndex) unless isClosed
        
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
      
      @curves.push curve
      
    for startSegmentIndex in [0...@edgeSegments.length]
      clockwise = null
      endSegmentIndex = startSegmentIndex
      setNewMainSegment = true
      segmentsInfo = []
      
      loop
        break unless nextSegment = getEdgeSegment endSegmentIndex + 1

        currentSegment = getEdgeSegment endSegmentIndex
        
        if setNewMainSegment
          mainDirection = currentSegment.edge
          mainDirectionIsAxisAligned = mainDirection.x is 0 or mainDirection.y is 0
          currentMainCount = currentSegment.count
          
          # Don't start on non-axis-aligned side-step segments except at the start of the line or if followed by a non-axis-aligned segment
          startingCurve = endSegmentIndex is startSegmentIndex
          nonAxisAligned = not mainDirectionIsAxisAligned
          isSideStep = currentMainCount is 1
          atStartOfLine = startSegmentIndex is 0
          followedByNonAxisAligned = nextSegment and (nextSegment.edge.x isnt 0 and nextSegment.edge.y isnt 0)
          
          break if startingCurve and nonAxisAligned and isSideStep and not (atStartOfLine or followedByNonAxisAligned)
          
          mainAngle = mainDirection.angle()
          setNewMainSegment = false
          
        segmentsInfo.push
          index: endSegmentIndex
          isSideStep: false
        
        nextSegmentAngle = nextSegment.edge.angle()
        nextSegmentClockwise = _.angleDifference(mainAngle, nextSegmentAngle) < 0
        
        if nextSegment.count > 1
          # The segment isn't a single side-step, so we have new tangent direction
          # but only continue the current curve if it has the same curvature direction.
          nextClockwise = nextSegmentClockwise
          setNewMainSegment = true

        else
          if mainDirectionIsAxisAligned
            # For axis-aligned directions, the curvature depends on the length of the segment after side-step, if we have it.
            if nextRepeatingSegment = getEdgeSegment endSegmentIndex + 2
              # If we're returning back to the original direction, we can
              # determine the direction based on change of repetition count.
              if nextRepeatingSegment.edge is mainDirection
                # Check if repetition count actually changed (otherwise we
                # can't determine it as it mimics a diagonal at this point).
                if currentMainCount is nextRepeatingSegment.count
                  # Move to next repeating segment (skip over side-step).
                  endSegmentIndex++
                  
                  segmentsInfo.push
                    index: endSegmentIndex + 1
                    isSideStep: true
                  
                else
                  # If the repeating count is decreasing, the curve curves in the same direction as the sidestep.
                  nextClockwise = if nextRepeatingSegment.count < currentMainCount then nextSegmentClockwise else not nextSegmentClockwise
                  currentMainCount = nextRepeatingSegment.count
                
                  # Check if we'll be terminating the curve due to change of direction.
                  unless clockwise? and nextClockwise isnt clockwise
                    # We're not terminating, we can move to the next repeating segment (skip over side-step).
                    endSegmentIndex++
                    
                    segmentsInfo.push
                      index: endSegmentIndex + 1
                      isSideStep: true
              
              else
                # The direction completely changes after the side-step, so for now just consider the side-step.
                nextClockwise = nextSegmentClockwise
                setNewMainSegment = true
    
            else
              # We do not have the second segment so the direction is then
              # simply the one from the next segment (since it's the last one).
              nextClockwise = nextSegmentClockwise
              
          else
            # We're turning away from a non-axis-aligned direction so we consider this a turn in direction.
            nextClockwise = nextSegmentClockwise
            setNewMainSegment = true
          
        # Terminate the curve if curvature changed.
        if clockwise?
          break if nextClockwise isnt clockwise
          
        else
          clockwise = nextClockwise
          
        endSegmentIndex++
        
        break if endSegmentIndex >= startSegmentIndex + @edgeSegments.length
        
      continue unless clockwise?

      addCurve startSegmentIndex, endSegmentIndex, segmentsInfo
      
      # No need to keep going if we found a closed curve.
      break if _.last(@curves).isClosed
