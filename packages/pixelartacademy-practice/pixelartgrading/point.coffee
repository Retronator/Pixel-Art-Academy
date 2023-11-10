AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

class PAG.Point
  @getSharedOutline: (pointA, pointB) ->
    for line in pointA.lines
      return line if line in pointB.lines and line.core
      
    null
  
  constructor: (@grading) ->
    @id = Random.id()
    
    @neighbors = []
    @lines = []
    @pixels = []
    
    @x = null
    @y = null
    
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

    @_updatePosition()
  
  _updatePosition: ->
    @x = 0
    @y = 0
    
    for pixel in @pixels
      @x += pixel.x
      @y += pixel.y
      
    @x /= @pixels.length
    @y /= @pixels.length
    
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
