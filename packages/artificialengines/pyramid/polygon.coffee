AE = Artificial.Everywhere
AP = Artificial.Pyramid

ConvexDecomposition = require 'poly-decomp'

class AP.Polygon
  constructor: (boundaryOrVertices) ->
    if boundaryOrVertices instanceof AP.PolygonBoundary
      @boundary = boundaryOrVertices
      
    else
      @boundary = new AP.PolygonBoundary boundaryOrVertices
      
    @boundary = @boundary.getBoundaryWithOrientation AP.PolygonBoundary.Orientations.CounterClockwise
    @vertices = @boundary.vertices

  getConvexPolygons: (quickDecomposition = true) ->
    polygons = []
    
    # Convert points to an array of arrays for convex decomposition.
    pointsArray = for vertex in @boundary.vertices
      [vertex.x, vertex.y]
    
    method = if quickDecomposition then 'quickDecomp' else 'decomp'
    convexPolygons = ConvexDecomposition[method] pointsArray
    
    for convexPolygon in convexPolygons
      points = for polygonPoint in convexPolygon
        x: polygonPoint[0], y: polygonPoint[1]
      
      polygons.push new AP.Polygon points
      
    polygons
  
  triangulate: (allowInvalid) ->
    trianglesCount = @vertices.length - 2
    indices = new Uint32Array trianglesCount * 3
    
    vertices = _.clone @boundary.vertices
    vertexIndices = [0...vertices.length]

    currentIndicesIndex = 0
    
    while vertices.length > 3
      # Remove a triangle on the inside that doesn't cross a boundary.
      triangleRemoved = false
      randomOffset = Math.floor Math.random() * vertices.length
      
      for index in [0...vertices.length]
        remainingVertexIndex = _.modulo index + randomOffset, vertices.length
        previousRemainingVertexIndex = _.modulo remainingVertexIndex - 1, vertices.length
        nextRemainingVertexIndex = _.modulo remainingVertexIndex + 1, vertices.length
        
        previousRemainingVertex = vertices[previousRemainingVertexIndex]
        remainingVertex = vertices[remainingVertexIndex]
        nextRemainingVertex = vertices[nextRemainingVertexIndex]

        # A triangle on the inside will have counter-clockwise orientation.
        continue if AP.PolygonBoundary.getSectionOrientation(previousRemainingVertex, remainingVertex, nextRemainingVertex) is AP.PolygonBoundary.Orientations.Clockwise
        
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
      if allowInvalid
        indices.error = true
        return indices
        
      else
        throw new AE.InvalidOperationException "The polygon was not able to be triangulated."
      
    # Fill the last triangle.
    indices[currentIndicesIndex + remainingVertexIndex] = vertexIndices[remainingVertexIndex] for remainingVertexIndex in [0..2]
    
    indices
