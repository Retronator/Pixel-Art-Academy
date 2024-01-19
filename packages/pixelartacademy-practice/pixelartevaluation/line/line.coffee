AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

class PAE.Line
  @WidthType:
    Thin: 'Thin'
    Thick: 'Thick'
    Wide: 'Wide'
    Variable: 'Variable'
    
  constructor: (@layer) ->
    @id = Random.id()
    
    @pixels = []
    @points = []
    @core = null
    
    @isClosed = false

    @edges = []
    @edgeSegments = []

    @potentialParts = []
    @potentialStraightLineParts = []
    @potentialCurveParts = []
    @pointPartIsCurve = []
    
    @parts = []
    
  destroy: ->
    pixel.unassignLine @ for pixel in @pixels
    point.unassignLine @ for point in @points
    @core?.unassignOutline @
    
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
    
    for point in @points[1...@points.length] when point not in cornerPoints
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
    
  getDoubles: ->
    return @_doubles if @_doubles
    
    @_doubles = []
    
    for edgeSegment in @edgeSegments when edgeSegment.isSideStep and edgeSegment.edge.isAxisAligned
      for pointIndex in [edgeSegment.startPointIndex, edgeSegment.endPointIndex]
        point = @getPoint pointIndex
        continue unless point.pixels.length is 1

        @_doubles.push point.pixels[0] unless point.pixels[0] in @_doubles
    
    @_doubles
    
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

  assignPoint: (point, end = true) ->
    throw new AE.ArgumentException "The point is already assigned to this line.", point, @ if point in @points

    if end
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