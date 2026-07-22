AP = Artificial.Pyramid

SectionOrientationEpsilon = 1e-10

getSectionDeterminant = (vertexA, vertexB, vertexC) ->
  (vertexB.x - vertexA.x) * (vertexC.y - vertexA.y) - (vertexC.x - vertexA.x) * (vertexB.y - vertexA.y)

getSignedDoubleAreaForVertices = (vertices) ->
  signedDoubleArea = 0

  for vertex, vertexIndex in vertices
    nextVertex = vertices[_.modulo vertexIndex + 1, vertices.length]
    signedDoubleArea += vertex.x * nextVertex.y - nextVertex.x * vertex.y

  signedDoubleArea

getTriangleSignedDoubleArea = (polygon, triangle) ->
  getSectionDeterminant(
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

Tinytest.add 'artificialengines - pyramid - polygon with holes triangulates without crossing edges', (test) ->
  polygon = new AP.PolygonWithHoles(
    new AP.PolygonBoundary [
      new THREE.Vector2 0, 0
      new THREE.Vector2 10, 0
      new THREE.Vector2 10, 4
      new THREE.Vector2 0, 4
    ]
    [
      new AP.PolygonBoundary [
        new THREE.Vector2 2, 1
        new THREE.Vector2 2, 3
        new THREE.Vector2 8, 3
        new THREE.Vector2 8, 1
      ]
    ]
  )

  triangles = polygon.triangulate()
  totalTriangleDoubleArea = 0

  for triangle in triangles
    triangleSignedDoubleArea = getTriangleSignedDoubleArea polygon, triangle

    test.isTrue triangleSignedDoubleArea > SectionOrientationEpsilon
    totalTriangleDoubleArea += triangleSignedDoubleArea

  expectedDoubleArea = getSignedDoubleAreaForVertices polygon.externalBoundary.vertices
  expectedDoubleArea += getSignedDoubleAreaForVertices internalBoundary.vertices for internalBoundary in polygon.internalBoundaries

  test.equal totalTriangleDoubleArea, expectedDoubleArea
  test.equal countCrossingTriangleEdges(polygon, triangles), 0
