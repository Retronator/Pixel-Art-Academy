AE = Artificial.Everywhere
AP = Artificial.Program
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

class PAE.Line
  @WidthType:
    Thin: 'Thin'
    Thick: 'Thick'
    Wide: 'Wide'
    Varying: 'Varying'
    Outline: 'Outline'
  
  @WidthConsistency:
    Consistent: 'Consistent'
    Varying: 'Varying'
    
  constructor: (@layer) ->
    @id = PAE.nextId()
    
    @pixels = []
    @points = []
    @core = null
    
    @isClosed = false

    @edges = []
    @edgeSegments = []

    # Potential parts are considered when determining whether a point on the line is part of a curve or a straight line.
    @potentialParts = []
    @potentialStraightLineParts = []
    @potentialCurveParts = []
    @pointPartIsCurve = []
    
    # Curvature curve parts are curve parts that connect the line between inflection points.
    @curvatureCurveParts = []
    @inflectionPoints = []
    
    @parts = []
    
  destroy: ->
    pixel.unassignLine @ for pixel in @pixels
    point.unassignLine @ for point in @points
    @core?.unassignOutline @
    
  getPixelBounds: ->
    return @_pixelBounds if @_pixelBounds
    
    minX = Number.POSITIVE_INFINITY
    maxX = Number.NEGATIVE_INFINITY
    minY = Number.POSITIVE_INFINITY
    maxY = Number.NEGATIVE_INFINITY
    
    for pixel in @pixels
      minX = pixel.x if pixel.x < minX
      maxX = pixel.x if pixel.x > maxX
      minY = pixel.y if pixel.y < minY
      maxY = pixel.y if pixel.y > maxY
    
    @_pixelBounds = {minX, maxX, minY, maxY}
  
  getCornerPoints: ->
    return @_cornerPoints if @_cornerPoints
    
    @_cornerPoints = []
    
    for part, partIndex in @parts[...@parts.length]
      nextPart = @parts[partIndex + 1]
      continue unless part instanceof @constructor.Part.StraightLine and nextPart instanceof @constructor.Part.StraightLine
      
      @_cornerPoints.push @getPoint part.endPointIndex
    
    @_cornerPoints
    
  getJaggies: ->
    return @_jaggies if @_jaggies
    
    @_jaggies = []
    cornerPoints = @getCornerPoints()
    
    # Ignore end points if the line is not closed.
    points = if @isClosed then @points else @points[1...@points.length - 1]
    
    for point in points when point not in cornerPoints
      for pixel in point.pixels
        if @_isJaggyInCorner(pixel, -1, -1) or @_isJaggyInCorner(pixel, -1, 1) or @_isJaggyInCorner(pixel, 1, -1) or @_isJaggyInCorner(pixel, 1, 1)
          @_jaggies.push pixel unless pixel in @_jaggies
    
    @_jaggies
    
  _isJaggyInCorner: (pixel, dx, dy) ->
    # A jaggy will have a diagonal neighbor and its two direct neighbors empty.
    return if @layer.getPixel pixel.x + dx, pixel.y + dy
    return if @layer.getPixel pixel.x, pixel.y + dy
    return if @layer.getPixel pixel.x + dx, pixel.y
    true
    
  getDoubles: (pixelArtEvaluationProperty) ->
    options = PAE._getEvaluationOptions(pixelArtEvaluationProperty).pixelPerfectLines.doubles
    optionsHash = AP.HashFunctions.getObjectHash options, AP.HashFunctions.circularShift5
    
    @_doubles ?= {}
    return @_doubles[optionsHash] if @_doubles[optionsHash]
    
    @_doubles[optionsHash] = []
    
    unless options.countAllLineWidthTypes
      # We should only count doubles on lines with varying width.
      width = @_analyzeWidth pixelArtEvaluationProperty
      return @_doubles[optionsHash] unless width.type is @constructor.WidthType.Varying
    
    # Doubles are all pixels on single-width (thick line) axis-aligned side steps.
    for edgeSegment in @edgeSegments when edgeSegment.isSideStep and edgeSegment.edge.isAxisAligned
      for pointIndex in [edgeSegment.startPointIndex, edgeSegment.endPointIndex]
        point = @getPoint pointIndex
        continue unless point.pixels.length is 1

        @_doubles[optionsHash].push point.pixels[0] unless point.pixels[0] in @_doubles[optionsHash]
        
    if options.countPointsWithMultiplePixels
      # Doubles are all pixels on points with multiple pixels.
      for point in @points when point.pixels.length > 1
        for pixel in point.pixels
          @_doubles[optionsHash].push pixel unless pixel in @_doubles
    
    @_doubles[optionsHash]
    
  getCorners: (pixelArtEvaluationProperty) ->
    options = PAE._getEvaluationOptions(pixelArtEvaluationProperty).pixelPerfectLines.corners
    optionsHash = AP.HashFunctions.getObjectHash options, AP.HashFunctions.circularShift5
    
    @_corners ?= {}
    return @_corners[optionsHash] if @_corners[optionsHash]
    
    @_corners[optionsHash] = []
    
    # Corners are pixels at the point between two consecutive axis-aligned edge segments that are not a side-step.
    for edgeSegment, edgeSegmentIndex in @edgeSegments when not edgeSegment.isSideStep
      break unless nextEdgeSegment = @getEdgeSegment edgeSegmentIndex + 1
      continue if nextEdgeSegment.isSideStep
      continue unless edgeSegment.edge.isAxisAligned and nextEdgeSegment.edge.isAxisAligned
      continue if edgeSegment.edge is nextEdgeSegment.edge
      
      # Ignore corners neighboring intersections with other lines.
      foundIntersection = false

      for pointIndexOffset in [-1..1]
        point = @getPoint edgeSegment.endPointIndex + pointIndexOffset
        # Note: We want to check for multiple neighbors and not lines
        # to catch places where double lines connect to outlines.
        if point.allNeighbors.length > 2
          foundIntersection = true
          break

      continue if foundIntersection
      
      if options.ignoreStraightLineCorners
        # Ignore corners between straight lines, we will assume they are intentional.
        continue unless @isPointPartCurve(edgeSegment.endPointIndex) and @isPointPartCurve(edgeSegment.endPointIndex - 1) and @isPointPartCurve(edgeSegment.endPointIndex + 1)
      
      point = @getPoint edgeSegment.endPointIndex
      for pixel in point.pixels
        @_corners[optionsHash].push pixel unless pixel in @_corners
        
    @_corners[optionsHash]
    
  getInnerPoints: ->
    return @_innerPoints if @_innerPoints
    
    @_innerPoints = _.filter @points, (point) -> point.neighbors.length is 2
    
    @_innerPoints
    
  getRightMostPoint: ->
    rightMostPoint = @points[0]
    
    rightMostPoint = point for point in @points[1..] when point.x > rightMostPoint.x
    
    rightMostPoint
  
  getPartsForPixel: (pixel) ->
    part for part in @parts when part.hasPixel pixel
    
  getEdgeSegment: (index) ->
    if @isClosed then @edgeSegments[_.modulo index, @edgeSegments.length] else @edgeSegments[index]

  getPoint: (index) ->
    if @isClosed then @points[_.modulo index, @points.length] else @points[index]
  
  getPart: (index) ->
    if @isClosed then @parts[_.modulo index, @parts.length] else @parts[index]

  isPointPartCurve: (index) ->
    if @isClosed then @pointPartIsCurve[_.modulo index, @points.length] else @pointPartIsCurve[index]

  assignPoint: (point, addAtEnd = true) ->
    throw new AE.ArgumentException "The point is already assigned to this line.", point, @ if point in @points

    if addAtEnd
      @points.push point
    
    else
      @points.unshift point
    
    @_cornerPoints = null
  
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
    
    @_jaggies = null
  
  mergeLine: (line) ->
    throw new AE.ArgumentException "The line can't be merged into itself.", line, @ if line is @
    throw new AE.ArgumentException "Closed lines can't be merged.", line, @ if @isClosed or line.isClosed

    startPoint = @points[0]
    endPoint = _.last @points
    
    otherStartPoint = line.points[0]
    otherEndPoint = _.last line.points

    # Find which endpoints touch and orient the merged points so the line remains a continuous sequence.
    if startPoint is otherStartPoint
      pointsToMerge = line.points[1...line.points.length]
      addAtEnd = false

    else if startPoint is otherEndPoint
      pointsToMerge = line.points[0...line.points.length - 1].reverse()
      addAtEnd = false

    else if endPoint is otherStartPoint
      pointsToMerge = line.points[1...line.points.length]
      addAtEnd = true

    else if endPoint is otherEndPoint
      pointsToMerge = line.points[0...line.points.length - 1].reverse()
      addAtEnd = true

    else
      throw new AE.ArgumentException "Lines don't share a matching endpoint.", line, @

    # If the other endpoint pair also matches, merging the line creates a closed loop.
    if addAtEnd
      if _.last(pointsToMerge) is startPoint
        pointsToMerge.pop()
        @isClosed = true

    else
      if pointsToMerge[0] is endPoint
        pointsToMerge.shift()
        @isClosed = true

    for point in pointsToMerge
      @_addExpansionPoint point, addAtEnd

    # Explicit return to avoid result collection.
    return

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
      
      # Merge with an existing line if we caught its start/end.
      if currentPoint.lines.length is 2
        otherLine = if currentPoint.lines[0] is @ then currentPoint.lines[1] else currentPoint.lines[0]
        @layer.mergeLineInto otherLine, @
        return

      else if currentPoint.lines.length > 2
        console.warn "Expanded into a point with 2 neighbors and more than 2 lines going through them."

      operation nextPoint
      
      previousPoint = currentPoint
      currentPoint = nextPoint
  
  _addExpansionPoint: (point, addAtEnd) ->
    @assignPoint point, addAtEnd
    point.assignLine @
    
    for pixel in point.pixels
      @addPixel pixel unless pixel in @pixels
  
  getCentralSegmentAveragePointIndex: (startSegmentIndex, endSegmentIndex = startSegmentIndex) ->
    averageSegmentIndex = (startSegmentIndex + endSegmentIndex) / 2
    centralSegments = [@getEdgeSegment(Math.floor averageSegmentIndex), @getEdgeSegment(Math.ceil averageSegmentIndex)]
    
    (centralSegments[0].endPointIndex + centralSegments[1].startPointIndex) / 2

  getCentralSegmentPosition: (startSegmentIndex, endSegmentIndex = startSegmentIndex) ->
    averagePointIndex = @getCentralSegmentAveragePointIndex startSegmentIndex, endSegmentIndex
    centralPoints = [@getPoint(Math.floor averagePointIndex), @getPoint(Math.ceil averagePointIndex)]

    x: (centralPoints[0].x + centralPoints[1].x) / 2
    y: (centralPoints[0].y + centralPoints[1].y) / 2

  isLineCurveBetweenEdgeSegments: (startEdgeSegmentIndex, endEdgeSegmentIndex) -> @_isLineCurveBetweenEdgeSegmentsValue startEdgeSegmentIndex, endEdgeSegmentIndex, true
  isLineStraightBetweenEdgeSegments: (startEdgeSegmentIndex, endEdgeSegmentIndex) -> @_isLineCurveBetweenEdgeSegmentsValue startEdgeSegmentIndex, endEdgeSegmentIndex, false
  
  _isLineCurveBetweenEdgeSegmentsValue: (startEdgeSegmentIndex, endEdgeSegmentIndex, value) ->
    startEdgeSegment = @getEdgeSegment startEdgeSegmentIndex
    endEdgeSegment = @getEdgeSegment endEdgeSegmentIndex
    startPointIndex = startEdgeSegment.startPointIndex
    endPointIndex = endEdgeSegment.endPointIndex
    
    for pointIndex in [startPointIndex..endPointIndex] when @isPointPartCurve(pointIndex) isnt value
      return false
      
    true
