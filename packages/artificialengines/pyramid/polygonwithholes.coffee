AE = Artificial.Everywhere
AP = Artificial.Pyramid

_bridge = new THREE.Line2
_externalBoundarySegment = new THREE.Line2
_I = new THREE.Vector2
_externalVertexDirection = new THREE.Vector2
_normal = new THREE.Vector2

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
    @externalBoundary = externalBoundary.getBoundaryWithOrientation AP.PolygonBoundary.Orientations.CounterClockwise
    @internalBoundaries = (internalBoundary.getBoundaryWithOrientation AP.PolygonBoundary.Orientations.Clockwise for internalBoundary in internalBoundaries)
    @boundaries = [@externalBoundary, @internalBoundaries...]

  getPolygonWithoutHoles: ->
    remainingInternalBoundaries = _.clone @internalBoundaries
    externalBoundary = @externalBoundary
    
    while remainingInternalBoundaries.length
      # Find right-most internal boundary vertex.
      maxInternalX = Number.NEGATIVE_INFINITY
      rightMostInternalBoundary = null
      rightMostInternalVertex = null
      rightMostInternalVertexIndex = null
      
      for internalBoundary in remainingInternalBoundaries
        for vertex, vertexIndex in internalBoundary.vertices
          continue if vertex.x <= maxInternalX
          
          rightMostInternalVertex = vertex
          rightMostInternalVertexIndex = vertexIndex
          maxInternalX = vertex.x
          rightMostInternalBoundary = internalBoundary
        
      _.pull remainingInternalBoundaries, rightMostInternalBoundary
      
      bridge = internalVertexIndex: rightMostInternalVertexIndex
      _bridge.start.copy rightMostInternalVertex
      
      # Find the potential external vertex to the right of the internal one and take the one that creates the shortest bridge.
      minBridgeLength = Number.POSITIVE_INFINITY
      
      for externalBridgeVertex, externalBridgeVertexIndex in externalBoundary.vertices when externalBridgeVertex.x >= rightMostInternalVertex.x
        # The internal vertex needs to be in the left half-plane of the external vertex.
        previousExternalVertex = externalBoundary.vertices[_.modulo externalBridgeVertexIndex - 1, externalBoundary.vertices.length]
        _externalBoundarySegment.start.copy previousExternalVertex
        _externalBoundarySegment.end.copy externalBridgeVertex
        continue if _externalBoundarySegment.isPointInRightHalfPlane rightMostInternalVertex
        
        nextExternalVertex = externalBoundary.vertices[_.modulo externalBridgeVertexIndex + 1, externalBoundary.vertices.length]
        _externalBoundarySegment.start.copy externalBridgeVertex
        _externalBoundarySegment.end.copy nextExternalVertex
        continue if _externalBoundarySegment.isPointInRightHalfPlane rightMostInternalVertex
        
        # Make sure the bridge doesn't cross any external boundary lines.
        _bridge.end.copy externalBridgeVertex
        intersectionFound = false

        for externalVertex, externalVertexIndex in externalBoundary.vertices
          nextExternalVertex = externalBoundary.vertices[_.modulo externalVertexIndex + 1, externalBoundary.vertices.length]
          continue if externalVertex.x < rightMostInternalVertex.x and nextExternalVertex.x < rightMostInternalVertexIndex.x
          _externalBoundarySegment.start.copy externalVertex
          _externalBoundarySegment.end.copy nextExternalVertex
          continue unless _bridge.intersects _externalBoundarySegment
          intersectionFound = true
          break
          
        continue if intersectionFound
        
        bridgeLength = _bridge.distance()
        
        if bridgeLength < minBridgeLength
          minBridgeLength = bridgeLength
          bridge.externalVertexIndex = externalBridgeVertexIndex
      
      unless bridge.externalVertexIndex?
        # Looks like no external vertex was found, something must be wrong.
        throw new AE.InvalidOperationException "The holes were not able to be removed."
        
      internalVertices = (rightMostInternalBoundary.getVertexAtIndex(index) for index in [bridge.internalVertexIndex..bridge.internalVertexIndex + rightMostInternalBoundary.sideCount])
      externalVertices = (externalBoundary.getVertexAtIndex(index) for index in [bridge.externalVertexIndex..bridge.externalVertexIndex + externalBoundary.sideCount])
      
      externalBoundary = new AP.PolygonBoundary [externalVertices..., internalVertices...]
      
    new AP.Polygon externalBoundary

  getInsetPolygon: (distance) ->
    insetExternalBoundary = @externalBoundary.getInsetPolygonBoundary distance
    outsetInternalBoundaries = (boundary.getInsetPolygonBoundary -distance for boundary in @internalBoundaries)
    
    new AP.PolygonWithHoles insetExternalBoundary, outsetInternalBoundaries
