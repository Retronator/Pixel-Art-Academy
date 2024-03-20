AP = Artificial.Pyramid

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
    # For each of the internal boundaries, find the shortest connector from its vertices to the external vertices.
    remainingInternalBoundaries = _.clone @internalBoundaries
    externalBoundary = @externalBoundary
    
    while remainingInternalBoundaries.length
      internalBoundary = remainingInternalBoundaries.pop()
      
      minConnectorLengthSquared = Number.POSITIVE_INFINITY
      minConnector = internalVertexIndex: null, externalVertexIndex: null
      
      for internalVertex, internalVertexIndex in internalBoundary.vertices
        for externalVertex, externalVertexIndex in externalBoundary.vertices
          lengthSquared = (internalVertex.x - externalVertex.x) ** 2 + (internalVertex.y - externalVertex.y) ** 2
          if lengthSquared < minConnectorLengthSquared
            minConnectorLengthSquared = lengthSquared
            minConnector.internalVertexIndex = internalVertexIndex
            minConnector.externalVertexIndex = externalVertexIndex
            
      internalVertices = (internalBoundary.getVertexAtIndex(index) for index in [minConnector.internalVertexIndex..minConnector.internalVertexIndex + internalBoundary.sideCount])
      externalVertices = (externalBoundary.getVertexAtIndex(index) for index in [minConnector.externalVertexIndex..minConnector.externalVertexIndex + externalBoundary.sideCount])
      
      externalBoundary = new AP.PolygonBoundary [externalVertices..., internalVertices...]
      
    new AP.Polygon externalBoundary
