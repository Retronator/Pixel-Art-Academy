# Math operations not available natively.

_.mixin
  # Calculates the remainder using floored division.
  modulo: (dividend, divisor) ->
    dividend - divisor * Math.floor(dividend / divisor)
    
  # Calculates the angle difference from a to b in the smallest direction.
  angleDifference: (a, b) ->
    difference = a - b
    Math.atan2 Math.sin(difference), Math.cos(difference)

  # Calculates the absolute smallest angle between two angles.
  angleDistance: (a, b) ->
    Math.abs _.angleDifference a, b
    
  angleBetweenPoints: (vertex, side1, side2) ->
    _.angleDistance Math.atan2(side1.y - vertex.y, side1.x - vertex.x), Math.atan2(side2.y - vertex.y, side2.x - vertex.x)

  # Calculates the largest positive integer that divides each of the integers (without a remainder).
  greatestCommonDivisor: (a, b) ->
    # Use Euclid's algorithm to reduce the integers until there's no remainder.
    [a, b] = [b, a % b] while b
    a
