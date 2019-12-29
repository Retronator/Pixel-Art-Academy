AP = Artificial.Pyramid

class AP.Interpolation.PiecewisePolynomial
  @ExtrapolationTypes:
    None: 'None'
    Constant: 'Constant'
    Polynomial: 'Polynomial'

  @getFunctionForPoints: (points, degree, extrapolateType = @ExtrapolationTypes.None) ->
    # Points need to be sorted.
    points = _.sortBy points, 'x'

    # Get x coordinates to perform binary search on.
    xValues = (point.x for point in points)
    xMin = xValues[0]
    xMax = _.last xValues

    # Decrease degree if there are not enough points present.
    degree = Math.min degree, points.length
    maxStartingPointIndex = points.length - degree

    # Cache polynomial functions.
    polynomials = {}

    ExtrapolationTypes = @ExtrapolationTypes

    (x) ->
      # See if we're within in bounds.
      unless xMin <= x <= xMax
        switch extrapolateType
          when ExtrapolationTypes.None
            # We don't do any interpolation.
            return

          when ExtrapolationTypes.Constant
            # We return the first or last point.
            if x < xMin
              return points[0].y

            else
              return _.last(points).y

      # Find the interval we need to interpolate on.
      interval = _.sortedIndex xValues, x
      interval-- unless xValues[interval] is x

      # Find the starting point from which to create a polynomial.
      startingPointIndex = _.clamp interval - Math.floor(degree / 2), 0, maxStartingPointIndex

      # Create the polynomial if needed.
      polynomials[startingPointIndex] ?= AP.Interpolation.LagrangePolynomial.getFunctionForPoints points[startingPointIndex..startingPointIndex + degree]

      # Return the value of the piecewise polynomial.
      polynomials[startingPointIndex] x
