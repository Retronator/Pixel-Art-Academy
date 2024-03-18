AP = Artificial.Pyramid

class AP.PolygonBoundary
  @Orientation:
    Clockwise: 'Clockwise'
    CounterClockwise: 'CounterClockwise'
  
  constructor: (@vertices) ->
    @sideCount = @vertices.length
  
  getVertexAtIndex: (index) ->
    return @vertices[_.modulo index, @vertices.length]

  getOrientation: ->
    return @_orientation if @_orientation
    
    # Find vertex with minimum x/y.
    minVertex = x: Number.POSITIVE_INFINITY
    minVertexIndex = null
    
    for vertex, index in @vertices
      if vertex.x < minVertex.x
        minVertex = vertex
        minVertexIndex = index
        
      else if vertex.x is minVertex.y and vertex.y < minVertex.y
        minVertex = vertex
        minVertexIndex = index
    
    # Calculate the determinant of the triangle spanning between the minimum vertex and two neighbors.
    previousVertex = @getVertexAtIndex minVertexIndex - 1
    nextVertex = @getVertexAtIndex minVertexIndex + 1

    # det(O) = (xB-xA)(yC-yA)-(xC-xA)(yB-yA)
    xA = previousVertex.x
    yA = previousVertex.y
    xB = minVertex.x
    yB = minVertex.y
    xC = nextVertex.x
    yC = nextVertex.y
    determinant = (xB - xA) * (yC - yA) - (xC - xA) * (yB - yA)
    
    if determinant < 0
      @_orientation = @constructor.Orientation.Clockwise
      
    else
      @_orientation = @constructor.Orientation.CounterClockwise
    
    @_orientation
    
  getPolygonBoundaryWithOrientation: (orientation) ->
    if orientation is @getOrientation()
      new @constructor _.clone @vertices
      
    else
      new @constructor _.reverse @vertices

  getBoundingRectangle: ->
    AP.BoundingRectangle.fromVertices @vertices
