AP = Artificial.Pyramid

_cameraWorldPosition = new THREE.Vector3()
_directionToCamera = new THREE.Vector3()
_vertexPosition0 = new THREE.Vector3()
_vertexPosition1 = new THREE.Vector3()
_vertexPosition2 = new THREE.Vector3()
_edge1 = new THREE.Vector3()
_edge2 = new THREE.Vector3()
_normal  = new THREE.Vector3()
_centroid  = new THREE.Vector3()

AP.TriangulatedSurface::getSilhouette = (surfaceWorldMatrix, camera) ->
  # Calculate edges if needed.
  @_calculateEdges() if not @_edges

  # Precompute world positions for every vertex (by vertex.index)
  unless @_vertexWorldPositions
    @_vertexWorldPositions = (new THREE.Vector3 for i in [0...@vertices.length])

  for vertex in @vertices
    @_vertexWorldPositions[vertex.index].copy(vertex).applyMatrix4 surfaceWorldMatrix

  # Prepare camera information.
  camera.getWorldPosition _cameraWorldPosition

  if camera.isOrthographicCamera
    # For an orthographic camera, we have a constant view direction toward the camera.
    camera.getWorldDirection(_directionToCamera).negate()

  # Classify each triangle as front or back facing.
  triangleIsFrontFacingMap = new WeakMap()

  for triangle in @triangles
    triangleVertex0 = triangle.vertices[0]
    triangleVertex1 = triangle.vertices[1]
    triangleVertex2 = triangle.vertices[2]

    _vertexPosition0.copy @_vertexWorldPositions[triangleVertex0.index]
    _vertexPosition1.copy @_vertexWorldPositions[triangleVertex1.index]
    _vertexPosition2.copy @_vertexWorldPositions[triangleVertex2.index]

    # Calculate the normal of the triangle: (v1 - v0) x (v2 - v0)
    _edge1.subVectors _vertexPosition1, _vertexPosition0
    _edge2.subVectors _vertexPosition2, _vertexPosition0
    _normal.crossVectors _edge1, _edge2

    if camera.isPerspectiveCamera
      # Perspective camera needs a direction calculated per triangle.
      _centroid.set(
        (_vertexPosition0.x + _vertexPosition1.x + _vertexPosition2.x) / 3.0,
        (_vertexPosition0.y + _vertexPosition1.y + _vertexPosition2.y) / 3.0,
        (_vertexPosition0.z + _vertexPosition1.z + _vertexPosition2.z) / 3.0
      )
      
      _directionToCamera.subVectors _cameraWorldPosition, _centroid
      
    triangleIsFrontFacingMap.set triangle, _normal.dot(_directionToCamera) > 1e-12

  # Collect silhouette edges.
  silhouette = []

  for edge in @_edges
    frontFacing0 = triangleIsFrontFacingMap.get edge.triangles[0]

    if edge.triangles.length is 1
      # We have a boundary edge. It's part of the silhouette if the single face is front-facing.
      continue unless frontFacing0

    else if edge.triangles.length >= 2
      # We have a normal edge. It's part of the silhouette if one if front and one back-facing.
      frontFacing1 = triangleIsFrontFacingMap.get edge.triangles[1]
      continue if frontFacing0 is frontFacing1
    
    lowVertexPosition = @_vertexWorldPositions[edge.lowVertex.index]
    highVertexPosition = @_vertexWorldPositions[edge.highVertex.index]
    
    silhouette.push
      edge: edge
      lowVertex: edge.lowVertex
      highVertex: edge.highVertex
      lowVertexPosition: lowVertexPosition.clone()
      highVertexPosition: highVertexPosition.clone()
      
  # Create silhouette loops.
  silhouetteEdgesSet = new Set()
  silhouetteEdgesSet.add segment.edge for segment in silhouette

  visitedSilhouetteEdgesSet = new Set()

  # Prepare for calculating the degree in silhouette (how many incident silhouette edges a vertex has).
  silhouetteVertexDegreeMap = new Map()
  
  getSilhouetteVertexDegree = (vertex) ->
    degree = silhouetteVertexDegreeMap.get vertex
    return degree if degree?
    
    degree = 0
    degree++ for edge in vertex.edges when silhouetteEdgesSet.has edge
    silhouetteVertexDegreeMap.set vertex, degree
    degree
  
  # Given a vertex and the edge we came from, pick the next silhouette edge.
  getNextSilhouetteEdge = (vertex, previousEdge) ->
    for edge in vertex.edges
      continue unless silhouetteEdgesSet.has edge
      continue if edge is previousEdge
      continue if visitedSilhouetteEdgesSet.has edge
      return edge
      
    null

  # Create a point with world position and normalized device coordinates.
  unless @_vertexNormalizedDeviceCoordinates
    @_vertexNormalizedDeviceCoordinates = (new THREE.Vector3 for i in [0...@vertices.length])

  getPointForVertex = (vertex) =>
    world = @_vertexWorldPositions[vertex.index]
    @_vertexNormalizedDeviceCoordinates[vertex.index].copy(world).project camera
    
    { vertex, world, normalizedDeviceCoordinates: @_vertexNormalizedDeviceCoordinates[vertex.index] }

  # Trace a chain/loop starting from a start vertex and (optionally) a starting edge.
  getPolygonalChainFromSilhouette = (startVertex, startEdge) ->
    startPoint = getPointForVertex startVertex
    polygonalChainPoints = [startPoint]

    currentVertex = startVertex
    previousEdge = null
    edge = startEdge

    # Choose direction so we move out of the start vertex along the edge
    visitedSilhouetteEdgesSet.add edge
    secondVertex = if currentVertex is edge.lowVertex then edge.highVertex else edge.lowVertex
    nextVertex = secondVertex

    loop
      polygonalChainPoints.push getPointForVertex nextVertex

      # At the new vertex, choose the next unvisited silhouette edge.
      previousEdge = edge
      currentVertex = nextVertex
      edge = getNextSilhouetteEdge currentVertex, previousEdge

      if edge
        visitedSilhouetteEdgesSet.add edge
        nextVertex = if edge.lowVertex is currentVertex then edge.highVertex else edge.lowVertex
        
        # If we returned to the starting vertex and it’s a closed loop, stop (and keep the closing point).
        if nextVertex is startVertex and getSilhouetteVertexDegree(startVertex) is 2
          polygonalChainPoints.push startPoint
          break
          
      else
        # There is next edge so we reached a dDead end (an open chain).
        break
        
    # Determine whether this chain has front-facing triangles on the left or right.
    triangle = startEdge.triangles[0]
    
    # Find the third vertex that is neither startVertex nor secondVertex
    otherVertex = null
    
    for vertex in triangle.vertices
      if vertex isnt startVertex and vertex isnt secondVertex
        otherVertex = vertex
        break
        
    otherPoint = getPointForVertex otherVertex
    
    sectionOrientation = AP.PolygonBoundary.getSectionOrientation(
      polygonalChainPoints[0].normalizedDeviceCoordinates
      polygonalChainPoints[1].normalizedDeviceCoordinates
      otherPoint.normalizedDeviceCoordinates
    )
    
    polygonalChainPoints.reverse() if sectionOrientation is AP.PolygonBoundary.Orientations.CounterClockwise
    
    new AP.PolygonalChain (new THREE.Vector2().copy point.normalizedDeviceCoordinates for point in polygonalChainPoints)

  polygonalChains = []

  # Prefer tracing from endpoints (degree != 2) to get open chains first.
  endpoints = []
  endpointsSet = new Set()
  
  for segment in silhouette
    for vertex in [segment.lowVertex, segment.highVertex]
      unless endpointsSet.has(vertex) or getSilhouetteVertexDegree(vertex) is 2
        endpoints.push vertex
        endpointsSet.add vertex

  for vertex in endpoints
    # Trace as many times as needed (edges will get marked as visited).
    loop
      # Find an unvisited silhouette edge leaving the vertex.
      startEdge = null
      
      for edge in vertex.edges
        if silhouetteEdgesSet.has(edge) and not visitedSilhouetteEdgesSet.has(edge)
          startEdge = edge
          break
          
      break unless startEdge?
      polygonalChain = getPolygonalChainFromSilhouette vertex, startEdge
      polygonalChains.push polygonalChain if polygonalChain.vertices.length >= 2

  # Trace the remaining closed loops (all degree 2).
  for segment in silhouette
    # Pick any vertex with an unvisited silhouette edge and walk until we return.
    edge = segment.edge
    continue if visitedSilhouetteEdgesSet.has edge
    
    # Pick a start vertex deterministically.
    startVertex = if segment.lowVertex.index <= segment.highVertex.index then segment.lowVertex else segment.highVertex
    polygonalChain = getPolygonalChainFromSilhouette startVertex, edge
    polygonalChains.push polygonalChain if polygonalChain.vertices.length >= 3 # Closed loops include repeated start at end.
  
  polygonalChains
