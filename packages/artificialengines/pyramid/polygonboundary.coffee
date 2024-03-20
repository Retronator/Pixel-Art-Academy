AP = Artificial.Pyramid

class AP.PolygonBoundary
  @Orientation:
    Clockwise: 'Clockwise'
    CounterClockwise: 'CounterClockwise'
    
  @getSectionOrientation: (vertexA, vertexB, vertexC) ->
    # det(O) = (xB-xA)(yC-yA)-(xC-xA)(yB-yA)
    xA = vertexA.x
    yA = vertexA.y
    xB = vertexB.x
    yB = vertexB.y
    xC = vertexC.x
    yC = vertexC.y
    determinant = (xB - xA) * (yC - yA) - (xC - xA) * (yB - yA)
    
    if determinant < 0
      @Orientation.Clockwise
    
    else
      @Orientation.CounterClockwise
  
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

    @_orientation = @constructor.getSectionOrientation previousVertex, minVertex, nextVertex
    @_orientation
    
  getPolygonBoundaryWithOrientation: (orientation) ->
    if orientation is @getOrientation()
      new @constructor _.clone @vertices
      
    else
      new @constructor _.reverse @vertices

  getBoundingRectangle: ->
    AP.BoundingRectangle.fromVertices @vertices
