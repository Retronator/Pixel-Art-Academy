AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

class PAE.Point
  @getSharedOutlineCore: (pointA, pointB) ->
    return unless outlinePixelA = pointA.getOutlinePixel()
    return unless outlinePixelB = pointB.getOutlinePixel()
    
    for outlineCore in outlinePixelA.outlineCores
      return outlineCore if outlineCore in outlinePixelB.outlineCores
      
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
    @id = PAE.nextId()
    
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

  getOutlines: ->
    line for line in @lines when line.core
    
  getOutlinePixel: ->
    return unless @pixels.length is 1 and @pixels[0].outlineCores.length
    @pixels[0]
  
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
          
  _connectNeighbor: (neighbor) ->
    @neighbors.push neighbor unless neighbor in @neighbors
    
  _disconnectNeighbor: (neighbor) ->
    _.pull @neighbors, neighbor
    
  _distanceTo: (point) ->
    (point.x - @x) ** 2 + (point.y - @y) ** 2
