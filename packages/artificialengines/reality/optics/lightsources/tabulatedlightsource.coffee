AE = Artificial.Everywhere
AR = Artificial.Reality

class AR.Optics.LightSources.TabulatedLightSource extends AR.Optics.LightSources.LightSource
  @initialize: (table) ->
    @table = AE.CSVParser.parse table
    values = []

    for row, index in @table
      # Transform text to numbers.
      row[0] = parseInt row[0]
      row[1] = parseFloat row[1]

      values[index] = row[1]

    startingWavelength = @table[0][0] * 1e-9
    wavelengthSpacing = (@table[1][0] - @table[0][0]) * 1e-9

    @_relativeEmissionSpectrum = new AR.Optics.Spectrum.UniformlySampled {values, startingWavelength, wavelengthSpacing}

    @relativeLuminance = @getRelativeLuminance()

  @getRelativeEmissionSpectrum: -> @_relativeEmissionSpectrum
