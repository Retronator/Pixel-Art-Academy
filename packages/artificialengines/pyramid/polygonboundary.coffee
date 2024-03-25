AP = Artificial.Pyramid

_delta = new THREE.Vector2
_normal = new THREE.Vector2

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
    
  isVertexAtIndexReflex: (index) ->
    previousVertex = @getVertexAtIndex index - 1
    vertex = @getVertexAtIndex index
    nextVertex = @getVertexAtIndex index + 1
    
    @getOrientation() isnt @constructor.getSectionOrientation previousVertex, vertex, nextVertex

  getOrientation: ->
    return @_orientation if @_orientation
    
    # Find vertex with minimum x/y.
    minVertex = x: Number.POSITIVE_INFINITY
    minVertexIndex = null
    
    for vertex, index in @vertices
      if vertex.x < minVertex.x
        minVertex = vertex
        minVertexIndex = index
        
      else if vertex.x is minVertex.x and vertex.y < minVertex.y
        minVertex = vertex
        minVertexIndex = index
    
    # Calculate the determinant of the triangle spanning between the minimum vertex and two neighbors.
    previousVertex = @getVertexAtIndex minVertexIndex - 1
    nextVertex = @getVertexAtIndex minVertexIndex + 1

    @_orientation = @constructor.getSectionOrientation previousVertex, minVertex, nextVertex
    @_orientation
    
  getPolygonBoundaryWithOrientation: (orientation) ->
    vertices = _.clone @vertices
    _.reverse vertices unless orientation is @getOrientation()
   
    new @constructor vertices

  getBoundingRectangle: ->
    AP.BoundingRectangle.fromVertices @vertices
    
  getInsetPolygonBoundary: (distance) ->
    clockwiseVertices = @getPolygonBoundaryWithOrientation(AP.PolygonBoundary.Orientation.Clockwise).vertices
    
    lines = for startVertex, vertexIndex in clockwiseVertices
      endVertex = clockwiseVertices[_.modulo vertexIndex + 1, clockwiseVertices.length]
      new THREE.Line2 new THREE.Vector2().copy(startVertex), new THREE.Vector2().copy(endVertex)
    
    # Inset all lines to the right.
    for line in lines
      line.getNormal true, _normal
      _normal.multiplyScalar distance
      line.start.add _normal
      line.end.add _normal
    
    # Create new vertices by intersecting the lines.
    insetVertices = for line, lineIndex in lines
      previousLine = lines[_.modulo lineIndex - 1, lines.length]
      insetVertex = new THREE.Vector2
      
      unless line.intersect previousLine, insetVertex
        insetVertex.copy line.start
      
      insetVertex
    
    _.reverse insetVertices unless @getOrientation() is AP.PolygonBoundary.Orientation.Clockwise
    
    new AP.PolygonBoundary insetVertices
