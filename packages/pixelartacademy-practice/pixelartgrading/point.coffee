AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

class PAG.Point
  @getSharedOutline: (pointA, pointB) ->
    for line in pointA.lines
      return line if line in pointB.lines and line.core
      
    null
    
  @setStraightLine: (pointA, pointB, line) ->
    if pointA.x < pointB.x
      line.start.x = pointA.x - pointA.radius
      line.end.x = pointB.x + pointB.radius
      
    else if pointA.x is pointB.x
      line.start.x = pointA.x
      line.end.x = pointB.x
    
    else
      line.start.x = pointA.x + pointA.radius
      line.end.x = pointB.x - pointB.radius
      
    if pointA.y < pointB.y
      line.start.y = pointA.y - pointA.radius
      line.end.y = pointB.y + pointB.radius
    
    else if pointA.y is pointB.y
      line.start.y = pointA.y
      line.end.y = pointB.y
    
    else
      line.start.y = pointA.y + pointA.radius
      line.end.y = pointB.y - pointB.radius
      
  constructor: (@layer) ->
    @id = Random.id()
    
    @neighbors = []
    @lines = []
    @pixels = []
    
    @x = null
    @y = null
    @radius = null
    
  destroy: ->
    pixel.unassignPoint @ for pixel in @pixels
    line.unassignPoint @ for line in @lines
    neighbor._disconnectNeighbor @ for neighbor in @neighbors
  
  assignLine: (line) ->
    throw new AE.ArgumentException "The line is already assigned to this point.", line if line in @lines
    @lines.push line
    
  unassignLine: (line) ->
    throw new AE.ArgumentException "The line is not assigned to this point.", line unless line in @lines
    _.pull @lines, line

  addPixel: (pixel) ->
    @pixels.push pixel
    pixel.assignPoint @

    @_updateProperties()
  
  _updateProperties: ->
    @x = 0
    @y = 0
    
    # We assume a symmetrical point for radius determination so only need to consider one axis.
    minX = Number.POSITIVE_INFINITY
    maxX = Number.NEGATIVE_INFINITY
    
    for pixel in @pixels
      @x += pixel.x
      @y += pixel.y
      
      minX = Math.min minX, pixel.x
      maxX = Math.max maxX, pixel.x
      
    @x /= @pixels.length
    @y /= @pixels.length
    
    size = maxX - minX + 1
    @radius = size / 2
    
  connectNeighbors: ->
    for pixel in @pixels
      pixel.forEachNeighbor (neighborPixel) =>
        for point in neighborPixel.points when point isnt @
          @_connectNeighbor point
          point._connectNeighbor @
          
  optimizeNeighbors: ->
    # Eliminate triangles by removing the longer sides.
    loop
      eliminated = false
      
      for neighborA in @neighbors
        distanceA = @_distanceTo neighborA
  
        for neighborB in @neighbors when neighborB isnt neighborA and neighborB in neighborA.neighbors
          distanceB = @_distanceTo neighborB
          distanceC = neighborA._distanceTo neighborB
          
          if distanceC > distanceA and distanceC > distanceB
            eliminatingPointA = neighborA
            eliminatingPointB = neighborB
            outsidePoint = @
            
          else
            eliminatingPointA = @
            eliminatingPointB = if distanceA > distanceB then neighborA else neighborB
            outsidePoint = if eliminatingPointB is neighborA then neighborB else neighborA
          
          # Do not remove outline edges if that would break the outline (the outside point is not on the outline).
          sharedOutline = @constructor.getSharedOutline eliminatingPointA, eliminatingPointB
          continue if sharedOutline and sharedOutline not in outsidePoint.lines
          
          eliminatingPointA._disconnectNeighbor eliminatingPointB
          eliminatingPointB._disconnectNeighbor eliminatingPointA
          
          eliminated = true
          break
          
        break if eliminated
        
      break unless eliminated
      
    # TODO: Remove inner core edges.
    # for line in @lines when line.core
    
  _connectNeighbor: (neighbor) ->
    @neighbors.push neighbor unless neighbor in @neighbors
    
  _disconnectNeighbor: (neighbor) ->
    _.pull @neighbors, neighbor
    
  _distanceTo: (point) ->
    (point.x - @x) ** 2 + (point.y - @y) ** 2
