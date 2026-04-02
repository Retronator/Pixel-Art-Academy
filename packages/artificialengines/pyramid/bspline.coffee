AP = Artificial.Pyramid

class AP.BSpline
  @getPointOnQuadraticBSpline: (point0, point1, point2, parameter, result) ->
    t = parameter
    result ?= {}
    
    for coordinate of point0
      p0 = point0[coordinate]
      p1 = point1[coordinate]
      p2 = point2[coordinate]
      result[coordinate] = 0.5 * (1 - t) ** 2 * p0 + (-t ** 2 + t + 0.5) * p1 + 0.5 * t ** 2 * p2

    result

  @getPointOnCubicBSpline: (point0, point1, point2, point3, parameter, result) ->
    t = parameter
    result ?= {}

    for coordinate of point0
      p0 = point0[coordinate]
      p1 = point1[coordinate]
      p2 = point2[coordinate]
      p3 = point3[coordinate]
      result[coordinate] = (1 - t) ** 3 / 6 * p0 + (3 * t ** 3 - 6 * t ** 2 + 4) / 6 * p1 + (-3 * t ** 3 + 3 * t ** 2 + 3 * t + 1) / 6 * p2 + t ** 3 / 6 * p3

    result

  constructor: (@points) ->

  getPolygonalChain: (vertexCount) ->
    vertices = []

    switch @points.length
      when 3
        for vertexIndex in [0...vertexCount]
          vertices.push @constructor.getPointOnQuadraticBSpline @points[0], @points[1], @points[2], vertexIndex / (vertexCount - 1), new THREE.Vector2

      when 4
        for vertexIndex in [0...vertexCount]
          vertices.push @constructor.getPointOnCubicBSpline @points[0], @points[1], @points[2], @points[3], vertexIndex / (vertexCount - 1), new THREE.Vector2

    new AP.PolygonalChain vertices
