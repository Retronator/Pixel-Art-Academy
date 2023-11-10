AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

edgeVectors = {}

getEdgeVector = (x, y) ->
  edgeVectors[x] ?= {}
  edgeVectors[x][y] ?= new THREE.Vector2 x, y
  edgeVectors[x][y]

class PAG.Line
  constructor: (@grading) ->
    @id = Random.id()
    
    @pixels = []
    @points = []
    @core = null
    
    @isClosed = false

    @edges = []
    @diagonals = []
    
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
      
    # Detect perfect diagonals.
    getEdge = (index) => if @isClosed then @edges[index % @edges.length] else @edges[index]
    getPoint = (index) => if @isClosed then @points[index % @points.length] else @points[index]

    lastDiagonalStartIndex = null
    lastDiagonalEndIndex = null
    
    addDiagonal = (startIndex, endIndex) =>
      # Don't add diagonals that are already contained within the last diagonal.
      return if lastDiagonalStartIndex? and startIndex >= lastDiagonalStartIndex and endIndex <= lastDiagonalEndIndex
      
      # Don't add horizontals or verticals.
      startPoint = getPoint startIndex
      endPoint = getPoint endIndex + 1
      return if startPoint.x is endPoint.x or startPoint.y is endPoint.y

      lastDiagonalStartIndex = startIndex
      lastDiagonalEndIndex = endIndex
      
      @diagonals.push
        startPoint: startPoint
        endPoint: endPoint
      
    for startIndex in [0...@edges.length]
      mainEdge = @edges[startIndex]
      mainEdgeCount = 1
      
      # Keep expanding until we hit a change.
      endIndex = startIndex
      
      loop
        endIndex++
        endEdge = getEdge endIndex
        break unless endEdge and endEdge is mainEdge
        
        mainEdgeCount++
        
      # If we came to the end, we have a straight line.
      unless endEdge
        addDiagonal startIndex, endIndex - 1
        break
        
      offEdge = endEdge
      
      # Try to find repetitions of main and off edges.
      lastRepetitionEndIndex = null
      repetitionFound = true
      
      loop
        for i in [0...mainEdgeCount]
          endIndex++
          endEdge = getEdge endIndex
          
          unless endEdge and endEdge is mainEdge
            repetitionFound = false
            break
        
        break unless repetitionFound

        lastRepetitionEndIndex = endIndex
        
        endIndex++
        endEdge = getEdge endIndex
        break unless endEdge and endEdge is offEdge
        
      if lastRepetitionEndIndex
        addDiagonal startIndex, lastRepetitionEndIndex
        
      else
        addDiagonal startIndex, startIndex + mainEdgeCount - 1
