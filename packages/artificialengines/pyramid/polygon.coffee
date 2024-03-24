AE = Artificial.Everywhere
AP = Artificial.Pyramid

ConvexDecomposition = require 'poly-decomp'

_delta = new THREE.Vector2
_normal = new THREE.Vector2

class AP.Polygon
  constructor: (boundaryOrVertices) ->
    if boundaryOrVertices instanceof AP.PolygonBoundary
      @boundary = boundaryOrVertices
      
    else
      @boundary = new AP.PolygonBoundary boundaryOrVertices

    @vertices = @boundary.vertices

  getConvexPolygons: (quickDecomposition = true) ->
    polygons = []
    
    # Convert points to an array of arrays for convex decomposition.
    pointsArray = for vertex in @boundary.getPolygonBoundaryWithOrientation(AP.PolygonBoundary.Orientation.CounterClockwise).vertices
      [vertex.x, vertex.y]
    
    method = if quickDecomposition then 'quickDecomp' else 'decomp'
    convexPolygons = ConvexDecomposition[method] pointsArray
    
    for convexPolygon in convexPolygons
      points = for polygonPoint in convexPolygon
        x: polygonPoint[0], y: polygonPoint[1]
      
      polygons.push new AP.Polygon points
      
    polygons
    
  getInsetPolygon: (distance) ->
    clockwiseVertices = @boundary.getPolygonBoundaryWithOrientation(AP.PolygonBoundary.Orientation.Clockwise).vertices
    
    lines = for startVertex, vertexIndex in clockwiseVertices
      endVertex = clockwiseVertices[_.modulo vertexIndex + 1, clockwiseVertices.length]
      new THREE.Line2 new THREE.Vector2().copy(startVertex), new THREE.Vector2().copy(endVertex)
      
    # Inset all lines to the right.
    for line in lines
      line.delta _delta
      _normal.x = _delta.y
      _normal.y = -_delta.x
      _normal.normalize().multiplyScalar distance
      line.start.add _normal
      line.end.add _normal
      
    # Create new vertices by intersecting the lines.
    insetVertices = for line, lineIndex in lines
      previousLine = lines[_.modulo lineIndex - 1, lines.length]
      insetVertex = new THREE.Vector2
      
      unless line.intersect previousLine, insetVertex
        insetVertex.copy line.start
        
      insetVertex
      
    _.reverse insetVertices unless @boundary.getOrientation() is AP.PolygonBoundary.Orientation.Clockwise
    
    new AP.Polygon insetVertices
  
  triangulate: ->
    trianglesCount = @vertices.length - 2
    
    indices = new Uint32Array trianglesCount * 3
    currentIndicesIndex = 0
    
    vertices = @boundary.getPolygonBoundaryWithOrientation(AP.PolygonBoundary.Orientation.CounterClockwise).vertices
    vertexIndices = [0...vertices.length]
    
    while vertices.length > 3
      # Remove a triangle on the inside that doesn't cross a boundary.
      triangleRemoved = false
      
      for remainingVertexIndex in [0...vertices.length]
        previousRemainingVertexIndex = _.modulo remainingVertexIndex - 1, vertices.length
        nextRemainingVertexIndex = _.modulo remainingVertexIndex + 1, vertices.length
        
        previousRemainingVertex = vertices[previousRemainingVertexIndex]
        remainingVertex = vertices[remainingVertexIndex]
        nextRemainingVertex = vertices[nextRemainingVertexIndex]

        # A triangle on the inside will have counter-clockwise orientation.
        continue if AP.PolygonBoundary.getSectionOrientation(previousRemainingVertex, remainingVertex, nextRemainingVertex) is AP.PolygonBoundary.Orientation.Clockwise
        
        # Triangle must not include any other vertices.
        containsOtherVertex = false
        
        for otherRemainingVertexIndex in [remainingVertexIndex + 2..remainingVertexIndex + vertices.length - 2]
          otherRemainingVertex = vertices[_.modulo otherRemainingVertexIndex, vertices.length]
          
          # We allow vertices to be on the triangle edge since some vertices are duplicated due to holes.
          continue if EJSON.equals(otherRemainingVertex, previousRemainingVertex) or EJSON.equals(otherRemainingVertex, remainingVertex) or EJSON.equals(otherRemainingVertex, nextRemainingVertex)
          
          # We are not on the edge, make sure we're not inside either.
          if THREE.Triangle2.containsPoint otherRemainingVertex, previousRemainingVertex, remainingVertex, nextRemainingVertex
            containsOtherVertex = true
            break
            
        continue if containsOtherVertex
        
        # We can remove this triangle.
        indices[currentIndicesIndex] = vertexIndices[previousRemainingVertexIndex]
        indices[currentIndicesIndex + 1] = vertexIndices[remainingVertexIndex]
        indices[currentIndicesIndex + 2] = vertexIndices[nextRemainingVertexIndex]
        currentIndicesIndex += 3
        
        vertices.splice remainingVertexIndex, 1
        vertexIndices.splice remainingVertexIndex, 1
        
        # Triangle removed, start again.
        triangleRemoved = true
        break
      continue if triangleRemoved
      
      # Looks like no triangle was removed, something must be wrong.
      throw new AE.InvalidOperationException "The polygon was not able to be triangulated."
      
    # Fill the last triangle.
    indices[currentIndicesIndex + remainingVertexIndex] = vertexIndices[remainingVertexIndex] for remainingVertexIndex in [0..2]
    
    indices
