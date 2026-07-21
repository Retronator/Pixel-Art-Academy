AE = Artificial.Everywhere
AP = Artificial.Pyramid

ConvexDecomposition = require 'poly-decomp'

class AP.Polygon
  constructor: (boundaryOrVertices) ->
    if boundaryOrVertices instanceof AP.PolygonBoundary
      @boundary = boundaryOrVertices
      
    else
      @boundary = new AP.PolygonBoundary boundaryOrVertices
      
    @boundary = @boundary.getBoundaryWithOrientation AP.PolygonBoundary.Orientations.CounterClockwise
    @vertices = @boundary.vertices

  getConvexPolygons: (quickDecomposition = true) ->
    polygons = []
    
    # Convert points to an array of arrays for convex decomposition.
    pointsArray = for vertex in @boundary.vertices
      [vertex.x, vertex.y]
    
    method = if quickDecomposition then 'quickDecomp' else 'decomp'
    convexPolygons = ConvexDecomposition[method] pointsArray
    
    for convexPolygon in convexPolygons
      points = for polygonPoint in convexPolygon
        x: polygonPoint[0], y: polygonPoint[1]
      
      polygons.push new AP.Polygon points
      
    polygons
  
  triangulate: ->
    triangulationVertices = for vertex in @vertices
      new THREE.Vector2 vertex.x, vertex.y

    THREE.ShapeUtils.triangulateShape triangulationVertices, []
