AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtEvaluation

class PAG.Pixel
  constructor: (@layer, @x, @y) ->
    @lines = []
    @points = []
    @core = null
    
    @isShallowCore = null
    @isDeepCore = null
    
  couldBeCore: -> @isShallowCore or @isDeepCore
  
  assignLine: (line) ->
    throw new AE.ArgumentException "The line is already assigned to this pixel.", line, @ if line in @lines
    @lines.push line
  
  assignPoint: (point) ->
    throw new AE.ArgumentException "The point is already assigned to this pixel.", point, @ if point in @points
    @points.push point
  
  assignCore: (core) ->
    throw new AE.ArgumentException "A core is already assigned to this pixel.", core, @ if @core
    @core = core

  unassignLine: (line) ->
    throw new AE.ArgumentException "The line is not assigned to this pixel.", line, @ unless line in @lines
    _.pull @lines, line
  
  unassignPoint: (point) ->
    throw new AE.ArgumentException "The point is not assigned to this pixel.", point, @ unless point in @points
    _.pull @points, point

  unassignCore: (core) ->
    throw new AE.ArgumentException "The core is not assigned to this pixel.", core, @ unless core is @core
    @core = null
  
  classifyCore: ->
    @isDeepCore = false
    @isShallowCore = false
  
    # Count number of neighbors.
    directNeighborsCount = 0
    diagonalNeighborsCount = 0
    
    @forEachNeighbor (pixel) =>
      if pixel.x is @x or pixel.y is @y
        directNeighborsCount++
        
      else
        diagonalNeighborsCount++
        
    # Core pixels have all direct neighbors.
    return unless directNeighborsCount is 4
    
    if diagonalNeighborsCount is 4
      @isDeepCore = true
      
    else
      @isShallowCore = true
  
  forEachNeighbor: (operation) ->
    for x in [@x - 1..@x + 1]
      for y in [@y - 1..@y + 1] when x isnt @x or y isnt @y
        if pixel = @layer.getPixel x, y
          operation pixel
        
    # Explicit return to avoid result collection.
    return
