AE = Artificial.Everywhere
AR = Artificial.Reality

class AR.Optics.LightSources.TabulatedLightSource extends AR.Optics.LightSources.LightSource
  @initialize: (table) ->
    @table = AE.CSVParser.parse table

    # Transform text to numbers.
    for row in @table
      row[0] = parseInt row[0]
      row[1] = parseFloat row[1]

    @relativeLuminance = @getRelativeLuminance()

  @getRelativeEmissionSpectrum: ->
    minTabulatedValue = @table[0][0]
    spacing = @table[1][0] - @table[0][0]
    table = @table

    # Return radiance in W / sr⋅m³
    (wavelength) ->
      wavelengthNanometers = wavelength * 1e9

      fractionalRow = (wavelengthNanometers - minTabulatedValue) / spacing

      middleRowIndex = _.clamp Math.round(fractionalRow), 1, table.length - 2

      rows = [
        table[middleRowIndex - 1]
        table[middleRowIndex]
        table[middleRowIndex + 1]
      ]

      x = (wavelengthNanometers - rows[0][0]) / spacing

      # The tabulated data doesn't provide valid values outside the tabulated range.
      return 0 unless 0 <= x <= 2

      y1 = rows[0][1]
      y2 = rows[1][1]
      y3 = rows[2][1]

      a = (y3 - 2 * y2 + y1) / 2
      b = (y3 - 4 * y2 + 3 * y1) / -2
      c = y1

      value = a * x * x + b * x + c

      Math.max 0, value
