AP = Artificial.Pyramid

class AP.Interpolation.LagrangePolynomial
  @getFunctionForPoints: (points) ->
    #        k
    # L(x) = ∑  yⱼlⱼ(x)
    #        j=0
    #
    #               x - xᵢ
    # lⱼ(x) =   ∏   -------
    #         0≤i<k xⱼ - xᵢ
    #          i≠j
    #
    k = points.length - 1

    (x) ->
      sum = 0

      for j in [0..k]
        xj = points[j].x
        yj = points[j].y
        lj = 1

        for i in [0..k] when i isnt j
          xi = points[i].x
          lj *= (x - xi) / (xj - xi)

        sum += yj * lj

      sum
