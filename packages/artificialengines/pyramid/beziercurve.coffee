AP = Artificial.Pyramid

class AP.BezierCurve
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
