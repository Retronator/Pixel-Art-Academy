AP = Artificial.Pyramid

class AP.BezierCurve
  @getPointOnQuadraticBezierCurve: (point0, point1, point2, parameter, result) ->
    t = parameter
    result ?= {}
    
    for coordinate of point0
      p0 = point0[coordinate]
      p1 = point1[coordinate]
      p2 = point2[coordinate]
      result[coordinate] = (1 - t) ** 2 * p0 + 2 * (1 - t) * t * p1 + t ** 2 * p2
    
    result
  
  @getPointOnCubicBezierCurve: (point0, point1, point2, point3, parameter, result) ->
    t = parameter
    result ?= {}
    
    for coordinate of point0
      p0 = point0[coordinate]
      p1 = point1[coordinate]
      p2 = point2[coordinate]
      p3 = point3[coordinate]
      result[coordinate] = (1 - t) ** 3 * p0 + 3 * (1 - t) ** 2 * t * p1 + 3 * (1 - t) * t ** 2 * p2 + t ** 3 * p3
      
    result

  constructor: (@points) ->
  
  getPolygonalChain: (vertexCount) ->
    vertices = []
    
    switch @points.length
      when 3
        for vertexIndex in [0...vertexCount]
          vertices.push @constructor.getPointOnQuadraticBezierCurve @points[0], @points[1], @points[2], vertexIndex / (vertexCount - 1), new THREE.Vector2
          
      when 4
        for vertexIndex in [0...vertexCount]
          vertices.push @constructor.getPointOnCubicBezierCurve @points[0], @points[1], @points[2], @points[3], vertexIndex / (vertexCount - 1), new THREE.Vector2
    
    new AP.PolygonalChain vertices
