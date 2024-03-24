AP = Artificial.Pyramid

_horizontal = new THREE.Line2
_externalBoundarySegment = new THREE.Line2
_I = new THREE.Vector2
_externalVertexDirection = new THREE.Vector2

class AP.PolygonWithHoles
  constructor: (boundariesOrExternalBoundary, internalBoundaries) ->
    if _.isArray boundariesOrExternalBoundary
      boundaries = boundariesOrExternalBoundary
      externalBoundary = _.maxBy boundaries, (boundary) => boundary.getBoundingRectangle().area
      internalBoundaries = _.without boundaries, externalBoundary
      
    else
      externalBoundary = boundariesOrExternalBoundary
    
    # To make the area of the polygon be on the left of the boundaries, we
    # make the external boundary counter-clockwise and internal ones clockwise.
    @externalBoundary = externalBoundary.getPolygonBoundaryWithOrientation AP.PolygonBoundary.Orientation.CounterClockwise
    @internalBoundaries = (internalBoundary.getPolygonBoundaryWithOrientation AP.PolygonBoundary.Orientation.Clockwise for internalBoundary in internalBoundaries)

  getPolygonWithoutHoles: ->
    # Based on Triangulation by Ear Clipping
    # David Eberly, Geometric Tools, Redmond WA 98052
    # https://www.geometrictools.com/Documentation/TriangulationByEarClipping.pdf
    remainingInternalBoundaries = _.clone @internalBoundaries
    externalBoundary = @externalBoundary
    
    while remainingInternalBoundaries.length
      # 1. Search the internal boundaries for vertex M of maximum x-value.
      maxInternalX = Number.NEGATIVE_INFINITY
      rightMostInternalBoundary = null
      M = null
      MIndex = null
      
      for internalBoundary in remainingInternalBoundaries
        for vertex, vertexIndex in internalBoundary.vertices
          continue if vertex.x <= maxInternalX
          
          M = vertex
          MIndex = vertexIndex
          maxInternalX = vertex.x
          rightMostInternalBoundary = internalBoundary
        
      _.pull remainingInternalBoundaries, rightMostInternalBoundary
      
      bridge = internalVertexIndex: MIndex
      
      # 2. Intersect the ray M + t(1, 0) with all directed edges ⟨Vi, Vi+1⟩ of the outer polygon for which M is to the
      # left of the line containing the edge. Moreover, the intersection tests need only involve directed edges for
      # which Vi is below (or on) the ray and Vi+1 is above (or on) the ray. This is essential when the polygon has
      # multiple holes and one or more holes have already had bridges inserted. Let I be the closest visible point to M
      # on the ray. The implementation keeps track of this by monitoring the t-value in search of the smallest positive
      # value for those edges in the intersection tests.
      # 3. If I is a vertex of the outer polygon, then M and I are mutually visible and the algorithm terminates.
      # 4. Otherwise, I is an interior point of the edge ⟨Vi,Vi+1⟩. Select P to be the endpoint of maximum x-value for this edge.
      _horizontal.start.copy M
      _horizontal.end.copy M
      _horizontal.end.x++
      minHorizontalDistance = Number.POSITIVE_INFINITY
      P = null
      PIndex = null
      
      for externalVertex, externalVertexIndex in externalBoundary.vertices
        nextExternalVertexIndex = externalVertexIndex + 1
        nextExternalVertex = externalBoundary.vertices[_.modulo nextExternalVertexIndex, externalBoundary.vertices.length]
        continue if externalVertex.y > M.y or nextExternalVertex.y < M.y or externalVertex.y is nextExternalVertex.y
        
        _externalBoundarySegment.start.copy externalVertex
        _externalBoundarySegment.end.copy nextExternalVertex
        horizontalDistance = _horizontal.intersectionDistanceFromStart _externalBoundarySegment
        continue unless 0 <= horizontalDistance < minHorizontalDistance
        
        minHorizontalDistance = horizontalDistance
        # Check for 3.
        if externalVertex.y is M.y
          P = externalVertex
          PIndex = externalVertexIndex
          
        else if nextExternalVertex.y is M.y
          P = nextExternalVertex
          PIndex = nextExternalVertexIndex
          
        else
          # Prepare for 4.
          P = if externalVertex.x > nextExternalVertex.x then externalVertex else nextExternalVertex
          PIndex = if P is externalVertex then externalVertexIndex else nextExternalVertexIndex
      
      if P.y is M.y
        # Case 3.
        bridge.externalVertexIndex = PIndex
      
      else
        # Case 4.
        # 5. Search the reflex vertices of the outer polygon, not including P if it happens to be reflex. If all of
        # these vertices are strictly outside triangle ⟨M,I,P⟩, then M and P are mutually visible and the algorithm
        # terminates.
        # 6. Otherwise, at least one reflex vertex lies in ⟨M,I,P⟩. Search for the reflex R that minimizes the
        # angle between ⟨M,I⟩ and ⟨M,R⟩; then M and R are mutually visible and the algorithm terminates.
        _I.copy M
        _I.x += horizontalDistance
        minAngle = Number.POSITIVE_INFINITY
        RIndex = null
        
        for externalVertex, externalVertexIndex in externalBoundary.vertices
          continue unless externalBoundary.isVertexAtIndexReflex externalVertexIndex
          continue unless THREE.Triangle2.containsPoint externalVertex, M, _I, P
          
          _externalVertexDirection.subVectors externalVertex, M
          angle = Math.abs _externalVertexDirection.angle()
          continue unless angle < minAngle
          
          minAngle = angle
          RIndex = externalVertexIndex
          
        if RIndex?
          bridge.externalVertexIndex = RIndex
          
        else
          bridge.externalVertexIndex = PIndex
          
      internalVertices = (rightMostInternalBoundary.getVertexAtIndex(index) for index in [bridge.internalVertexIndex..bridge.internalVertexIndex + rightMostInternalBoundary.sideCount])
      externalVertices = (externalBoundary.getVertexAtIndex(index) for index in [bridge.externalVertexIndex..bridge.externalVertexIndex + externalBoundary.sideCount])
      
      externalBoundary = new AP.PolygonBoundary [externalVertices..., internalVertices...]
      
    new AP.Polygon externalBoundary
