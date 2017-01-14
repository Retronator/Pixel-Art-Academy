# Math operations not available natively.

_.mixin
  # Calculates the remainder using floored division.
  modulo: (dividend, divisor) ->
    dividend - divisor * Math.floor(dividend / divisor)
