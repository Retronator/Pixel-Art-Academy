# Math operations not available natively.

_.mixin
  # Calculates the remainder using floored division.
  modulo: (dividend, divisor) ->
    dividend - divisor * Math.floor(dividend / divisor)

  # Calculates the absolute smallest angle between two angles.
  angleDistance: (a, b) ->
    difference = a - b
    Math.abs Math.atan2 Math.sin(difference), Math.cos(difference)
