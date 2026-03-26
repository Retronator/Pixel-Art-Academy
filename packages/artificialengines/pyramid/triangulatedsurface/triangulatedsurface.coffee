AP = Artificial.Pyramid

class AP.TriangulatedSurface
  @fromBufferGeometry: (geometry, options = {}) ->
    vertexDistanceTolerance = options.vertexDistanceTolerance ? 1e-6
    uniqueVertexIndices = options.uniqueVertexIndices ? []
    
    # Extract vertices from position attribute.
    vertices = []
    positions = geometry.attributes.position.array
    
    uniqueVertexMap = new Map()
    
    for vertexIndex in [0...positions.length / 3]
      coordinateIndex = vertexIndex * 3
      
      vertex = new THREE.Vector3(
        positions[coordinateIndex]
        positions[coordinateIndex + 1]
        positions[coordinateIndex + 2]
      )
      
      # Quantize vertex coordinates to integers based on the tolerance.
      quantizedKey = [
        Math.round vertex.x / vertexDistanceTolerance
        Math.round vertex.y / vertexDistanceTolerance
        Math.round vertex.z / vertexDistanceTolerance
      ].join ','
      
      if existingVertex = uniqueVertexMap.get quantizedKey
        vertex = existingVertex
        
      else
        vertex.index = vertices.length
        uniqueVertexMap.set quantizedKey, vertex
        vertices.push vertex
  
      uniqueVertexIndices.push vertex.index
    
    # Extract triangles from indices.
    triangles = []
    indices = geometry.index?.array or [0...positions.length / 3]
    
    for triangleIndex in [0...indices.length / 3]
      vertexIndexIndex = triangleIndex * 3
      triangle =
        index: triangleIndex
        vertices: [
          vertices[uniqueVertexIndices[indices[vertexIndexIndex]]]
          vertices[uniqueVertexIndices[indices[vertexIndexIndex + 1]]]
          vertices[uniqueVertexIndices[indices[vertexIndexIndex + 2]]]
        ]
        
      triangles.push triangle
    
    new @ vertices, triangles
  
  constructor: (@vertices, @triangles) ->
  
  morphVertices: (baseCoordinates, targets, uniqueVertexIndices) ->
    for vertexIndex in [0...baseCoordinates.length / 3]
      coordinateIndex = vertexIndex * 3
      
      targetVertexIndex = if uniqueVertexIndices then uniqueVertexIndices[vertexIndex] else vertexIndex
      targetVertex = @vertices[targetVertexIndex]
      
      targetVertex.x = baseCoordinates[coordinateIndex]
      targetVertex.y = baseCoordinates[coordinateIndex + 1]
      targetVertex.z = baseCoordinates[coordinateIndex + 2]
      
      for target in targets
        targetVertex.x += target.coordinates[coordinateIndex] * target.weight
        targetVertex.y += target.coordinates[coordinateIndex + 1] * target.weight
        targetVertex.z += target.coordinates[coordinateIndex + 2] * target.weight
  
    # Explicit return to prevent result collection.
    return
    
  getEdges: ->
    return @_edges if @_edges
    
    @_calculateEdges()
    @_edges
    
  getEdgesMap: ->
    return @_edgesMap if @_edgesMap
    
    @_calculateEdges()
    @_edgesMap
    
  _calculateEdges: ->
    @_edges = []
    @_edgesMap = new Map
    
    # Create edge arrays on vertices.
    v.edges ?= [] for v in @vertices
    
    # Create edges.
    for triangle, triangleIndex in @triangles
      for triangleVertexIndex in [0..2]
        vertexA = triangle.vertices[triangleVertexIndex]
        vertexB = triangle.vertices[(triangleVertexIndex + 1) % 3]

        if vertexA.index < vertexB.index
          lowVertex = vertexA
          highVertex = vertexB
          
        else
          lowVertex = vertexB
          highVertex = vertexA
        
        unless lowVertexEdgesMap = @_edgesMap.get lowVertex
          lowVertexEdgesMap = new Map
          @_edgesMap.set lowVertex, lowVertexEdgesMap
         
        unless edge = lowVertexEdgesMap.get highVertex
          edge =
            lowVertex: lowVertex
            highVertex: highVertex
            triangles: []
            
          lowVertex.edges.push edge
          highVertex.edges.push edge
          
          @_edges.push edge
          lowVertexEdgesMap.set highVertex, edge

        edge.triangles.push triangle
