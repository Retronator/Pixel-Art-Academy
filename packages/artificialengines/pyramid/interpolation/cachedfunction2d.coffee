AP = Artificial.Pyramid

class AP.Interpolation.CachedFunction2D
  @getCachedFunction: (inputFunction, spacing) ->
    coordinateMultiplier = 1 / spacing
    cachedValues = {}

    (x, y) ->
      # Scale coordinates to integer values.
      cx = x * coordinateMultiplier
      cy = y * coordinateMultiplier

      x1 = Math.floor cx
      x2 = x1 + 1

      y1 = Math.floor cy
      y2 = y1 + 1

      # Precalculate the values if needed.
      cachedValues[x1] ?= {}
      cachedValues[x2] ?= {}

      z11 = cachedValues[x1][y1] ?= inputFunction x, y
      z12 = cachedValues[x1][y2] ?= inputFunction x, y
      z21 = cachedValues[x2][y1] ?= inputFunction x, y
      z22 = cachedValues[x2][y2] ?= inputFunction x, y

      # Linearly interpolate between cached values.
      lx = cx - x1
      ly = cy - y1

      z1 = z11 * lx + z21 * (1 - lx)
      z2 = z12 * lx + z22 * (1 - lx)

      z1 * ly + z2 * (1 - ly)
