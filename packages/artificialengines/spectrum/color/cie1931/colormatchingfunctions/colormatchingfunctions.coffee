AS = Artificial.Spectrum

class AS.Color.CIE1931.ColorMatchingFunctions
  @x: (wavelength) -> @_interpolateTable 1, wavelength
  @y: (wavelength) -> @_interpolateTable 2, wavelength
  @z: (wavelength) -> @_interpolateTable 3, wavelength

  @_interpolateTable: (column, wavelength) ->
    fractionalRow = (wavelength - 380) / 5

    middleRowIndex = _.clamp Math.round(fractionalRow), 1, 79

    rows = [
      @table[middleRowIndex - 1]
      @table[middleRowIndex]
      @table[middleRowIndex + 1]
    ]

    x = (wavelength - rows[0][0]) / 5

    y1 = rows[0][column]
    y2 = rows[1][column]
    y3 = rows[2][column]

    a = (y3 - 2 * y2 + y1) / 2
    b = (y3 - 4 * y2 + 3 * y1) / -2
    c = y1

    value = a * x * x + b * x + c

    Math.max 0, value
