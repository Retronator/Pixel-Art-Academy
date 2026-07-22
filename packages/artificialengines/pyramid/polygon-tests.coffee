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

Tinytest.add 'artificialengines - pyramid - polygon triangulate ignores collinear ears', (test) ->
  polygon = new AP.Polygon [
    new THREE.Vector2 0, 0
    new THREE.Vector2 1, 0
    new THREE.Vector2 2, 0
    new THREE.Vector2 2, 1
    new THREE.Vector2 0, 1
  ]
  
  triangles = polygon.triangulate()
  totalTriangleDoubleArea = 0
  
  for triangle in triangles
    triangleSignedDoubleArea = getTriangleSignedDoubleArea polygon, triangle
    
    test.isTrue triangleSignedDoubleArea > SectionOrientationEpsilon
    totalTriangleDoubleArea += triangleSignedDoubleArea
    
  test.equal totalTriangleDoubleArea, getSignedDoubleAreaForVertices polygon.vertices
