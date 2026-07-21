AP = Artificial.Pyramid

createVertex = (x, y) ->
  new THREE.Vector2 x, y

getTriangleSignedDoubleArea = (polygon, triangle) ->
  AP.PolygonBoundary.getSectionDeterminant(
    polygon.vertices[triangle[0]]
    polygon.vertices[triangle[1]]
    polygon.vertices[triangle[2]]
  )

getTriangleEdges = (triangles) ->
  edges = []

  for triangle, triangleIndex in triangles
    edges.push [triangle[0], triangle[1], triangleIndex]
    edges.push [triangle[1], triangle[2], triangleIndex]
    edges.push [triangle[2], triangle[0], triangleIndex]
    
  edges

countCrossingTriangleEdges = (polygon, triangles) ->
  edges = getTriangleEdges triangles
  line = new THREE.Line2
  otherLine = new THREE.Line2
  crossingEdgesCount = 0
  
  for edge, edgeIndex in edges
    for otherEdge in edges[edgeIndex + 1..]
      continue if edge[2] is otherEdge[2]
      continue if edge[0] in [otherEdge[0], otherEdge[1]]
      continue if edge[1] in [otherEdge[0], otherEdge[1]]
      
      line.start.copy polygon.vertices[edge[0]]
      line.end.copy polygon.vertices[edge[1]]
      otherLine.start.copy polygon.vertices[otherEdge[0]]
      otherLine.end.copy polygon.vertices[otherEdge[1]]
      
      crossingEdgesCount++ if line.intersects otherLine
      
  crossingEdgesCount

Tinytest.add 'artificialengines - pyramid - polygon boundary orientation handles collinear sections', (test) ->
  collinearSectionOrientation = AP.PolygonBoundary.getSectionOrientation(
    createVertex 0, 0
    createVertex 1, 0
    createVertex 2, 0
  )
  
  test.equal collinearSectionOrientation, AP.PolygonBoundary.Orientations.Collinear
  
  boundary = new AP.PolygonBoundary [
    createVertex 0, 0
    createVertex 1, 0
    createVertex 2, 0
    createVertex 2, 1
    createVertex 0, 1
  ]
  
  test.equal boundary.getOrientation(), AP.PolygonBoundary.Orientations.CounterClockwise
  test.equal boundary.getBoundaryWithInvertedOrientation().getOrientation(), AP.PolygonBoundary.Orientations.Clockwise

Tinytest.add 'artificialengines - pyramid - polygon triangulate ignores collinear ears', (test) ->
  polygon = new AP.Polygon [
    createVertex 0, 0
    createVertex 1, 0
    createVertex 2, 0
    createVertex 2, 1
    createVertex 0, 1
  ]
  
  triangles = polygon.triangulate()
  totalTriangleDoubleArea = 0
  
  for triangle in triangles
    triangleSignedDoubleArea = getTriangleSignedDoubleArea polygon, triangle
    
    test.isTrue triangleSignedDoubleArea > AP.PolygonBoundary.SectionOrientationEpsilon
    totalTriangleDoubleArea += triangleSignedDoubleArea
    
  test.equal totalTriangleDoubleArea, AP.PolygonBoundary.getSignedDoubleAreaForVertices polygon.vertices

Tinytest.add 'artificialengines - pyramid - polygon with holes triangulates without crossing edges', (test) ->
  polygon = new AP.PolygonWithHoles(
    new AP.PolygonBoundary [
      createVertex 0, 0
      createVertex 10, 0
      createVertex 10, 4
      createVertex 0, 4
    ]
    [
      new AP.PolygonBoundary [
        createVertex 2, 1
        createVertex 2, 3
        createVertex 8, 3
        createVertex 8, 1
      ]
    ]
  )
  
  triangles = polygon.triangulate()
  totalTriangleDoubleArea = 0
  
  for triangle in triangles
    triangleSignedDoubleArea = getTriangleSignedDoubleArea polygon, triangle
    
    test.isTrue triangleSignedDoubleArea > AP.PolygonBoundary.SectionOrientationEpsilon
    totalTriangleDoubleArea += triangleSignedDoubleArea
    
  expectedDoubleArea = AP.PolygonBoundary.getSignedDoubleAreaForVertices(polygon.externalBoundary.vertices)
  expectedDoubleArea += AP.PolygonBoundary.getSignedDoubleAreaForVertices internalBoundary.vertices for internalBoundary in polygon.internalBoundaries
  
  test.equal totalTriangleDoubleArea, expectedDoubleArea
  test.equal countCrossingTriangleEdges(polygon, triangles), 0
