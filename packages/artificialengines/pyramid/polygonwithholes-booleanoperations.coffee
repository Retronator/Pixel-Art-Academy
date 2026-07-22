AP = Artificial.Pyramid

PolygonClipping = require 'polygon-clipping'

AP.PolygonWithHoles.getUnion = (polygons) ->
  return [] unless polygons.length

  # Convert our polygon objects to the nested coordinate arrays used by the clipping library.
  polygonCoordinates = (@_getPolygonClippingCoordinates polygon for polygon in polygons)
  unionCoordinates = PolygonClipping.union polygonCoordinates...

  @_createPolygonsFromPolygonClippingCoordinates unionCoordinates

AP.PolygonWithHoles.getDifference = (polygon, subtractingPolygons) ->
  return [polygon] unless subtractingPolygons.length

  # Subtract all polygons in one operation so the clipping library can retain disconnected regions and islands.
  polygonCoordinates = @_getPolygonClippingCoordinates polygon
  subtractingPolygonCoordinates = for subtractingPolygon in subtractingPolygons
    @_getPolygonClippingCoordinates subtractingPolygon

  differenceCoordinates = PolygonClipping.difference polygonCoordinates, subtractingPolygonCoordinates...

  @_createPolygonsFromPolygonClippingCoordinates differenceCoordinates

AP.PolygonWithHoles._getPolygonClippingCoordinates = (polygon) ->
  boundaries = polygon.boundaries or [polygon.boundary]

  for boundary in boundaries
    ([vertex.x, vertex.y] for vertex in boundary.vertices)

AP.PolygonWithHoles._createPolygonsFromPolygonClippingCoordinates = (multiPolygonCoordinates) ->
  for polygonCoordinates in multiPolygonCoordinates
    boundaries = for boundaryCoordinates in polygonCoordinates
      # Polygon Clipping closes every output ring by repeating its first vertex. Our boundaries are implicitly closed.
      uniqueBoundaryCoordinates = boundaryCoordinates[...-1]
      vertices = (new THREE.Vector2 coordinates[0], coordinates[1] for coordinates in uniqueBoundaryCoordinates)
      new AP.PolygonBoundary vertices

    new AP.PolygonWithHoles boundaries[0], boundaries[1..]
