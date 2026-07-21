AP = Artificial.Pyramid

class AP.BSpline
  @Degrees:
    Quadratic: 2
    Cubic: 3

  @getPointOnQuadraticBSpline: (point0, point1, point2, parameter, result) ->
    t = parameter
    result ?= {}
    
    for own coordinate of point0
      p0 = point0[coordinate]
      p1 = point1[coordinate]
      p2 = point2[coordinate]
      result[coordinate] = 0.5 * (1 - t) ** 2 * p0 + (-t ** 2 + t + 0.5) * p1 + 0.5 * t ** 2 * p2

    result

  @getPointOnCubicBSpline: (point0, point1, point2, point3, parameter, result) ->
    t = parameter
    result ?= {}

    for own coordinate of point0
      p0 = point0[coordinate]
      p1 = point1[coordinate]
      p2 = point2[coordinate]
      p3 = point3[coordinate]
      result[coordinate] = (1 - t) ** 3 / 6 * p0 + (3 * t ** 3 - 6 * t ** 2 + 4) / 6 * p1 + (-3 * t ** 3 + 3 * t ** 2 + 3 * t + 1) / 6 * p2 + t ** 3 / 6 * p3

    result

  constructor: (@points, @degree) ->
    @degree ?= if @points.length is 4 then @constructor.Degrees.Cubic else @constructor.Degrees.Quadratic

  getPolygonalChain: (vertexCount) ->
    vertices = []

    switch @degree
      when @constructor.Degrees.Quadratic
        return new AP.PolygonalChain vertices unless @points.length >= 3

        segmentCount = @points.length - 2

        for segmentIndex in [0...segmentCount]
          vertexStartIndex = if segmentIndex then 1 else 0

          for vertexIndex in [vertexStartIndex...vertexCount]
            parameter = vertexIndex / (vertexCount - 1)
            vertices.push @constructor.getPointOnQuadraticBSpline @points[segmentIndex], @points[segmentIndex + 1], @points[segmentIndex + 2], parameter, new THREE.Vector2

      when @constructor.Degrees.Cubic
        return new AP.PolygonalChain vertices unless @points.length >= 4

        segmentCount = @points.length - 3

        for segmentIndex in [0...segmentCount]
          vertexStartIndex = if segmentIndex then 1 else 0

          for vertexIndex in [vertexStartIndex...vertexCount]
            parameter = vertexIndex / (vertexCount - 1)
            vertices.push @constructor.getPointOnCubicBSpline @points[segmentIndex], @points[segmentIndex + 1], @points[segmentIndex + 2], @points[segmentIndex + 3], parameter, new THREE.Vector2

    new AP.PolygonalChain vertices
