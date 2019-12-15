AP = Artificial.Pyramid

AP.Integration.integrateWithMidpointRule = (integrand, lowerBound, upperBound, minimumSpacing) ->
  range = upperBound - lowerBound
  n = Math.ceil range / minimumSpacing
  spacing = range / n

  sum = 0

  for i in [0...n]
    x = lowerBound + spacing * (i + 0.5)
    sum += integrand x

  sum * spacing
