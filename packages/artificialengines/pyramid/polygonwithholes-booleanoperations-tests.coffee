AP = Artificial.Pyramid

createBoundary = (minX, minY, maxX, maxY) ->
  new AP.PolygonBoundary [
    new THREE.Vector2 minX, minY
    new THREE.Vector2 maxX, minY
    new THREE.Vector2 maxX, maxY
    new THREE.Vector2 minX, maxY
  ]

getTriangleDoubleArea = (polygon, triangle) ->
  vertexA = polygon.vertices[triangle[0]]
  vertexB = polygon.vertices[triangle[1]]
  vertexC = polygon.vertices[triangle[2]]

  Math.abs (vertexB.x - vertexA.x) * (vertexC.y - vertexA.y) - (vertexC.x - vertexA.x) * (vertexB.y - vertexA.y)

Tinytest.add 'artificialengines - pyramid - polygon with holes unions overlapping holes before triangulation', (test) ->
  playfieldPolygon = new AP.PolygonWithHoles createBoundary(0, 0, 10, 10), []
  holePolygons = [
    new AP.Polygon createBoundary 2, 2, 6, 6
    new AP.Polygon createBoundary 4, 4, 8, 8
  ]

  mergedHolePolygons = AP.PolygonWithHoles.getUnion holePolygons
  triangulationPolygons = AP.PolygonWithHoles.getDifference playfieldPolygon, mergedHolePolygons

  test.equal mergedHolePolygons.length, 1
  test.equal triangulationPolygons.length, 1
  test.equal triangulationPolygons[0].internalBoundaries.length, 1

  triangles = triangulationPolygons[0].triangulate()
  totalTriangleDoubleArea = _.sum (getTriangleDoubleArea triangulationPolygons[0], triangle for triangle in triangles)

  # The two 4-by-4 holes overlap by 2-by-2, leaving 72 square units of playfield.
  test.equal totalTriangleDoubleArea, 144
