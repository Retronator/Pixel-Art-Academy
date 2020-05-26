AE = Artificial.Everywhere
AR = Artificial.Reality

class AR.Optics.LightSources.CIE.D
  @initialize: (table) ->
    @table = AE.CSVParser.parse table

    # Transform text to numbers.
    for row in @table
      row[0] = parseInt row[0]
      row[i] = parseFloat row[i] for i in [1..3]

  @getEmissionSpectrumForCorrelatedColorTemperature: (correlatedColorTemperature) ->
    AS = Artificial.Spectrum

    return unless relativeEmissionSpectrum = @getRelativeEmissionSpectrumForCorrelatedColorTemperature correlatedColorTemperature
    relativeLuminance = AS.Color.CIE1931.getLuminanceForSpectrum relativeEmissionSpectrum

    blackBodySpectrum = AR.Optics.LightSources.BlackBody.getEmissionSpectrumForTemperature correlatedColorTemperature
    blackBodyLuminance = AS.Color.CIE1931.getLuminanceForSpectrum blackBodySpectrum

    # Return radiance in W / sr⋅m³
    new AR.Optics.Spectrum.Formulated (wavelength) -> relativeEmissionSpectrum.getValue(wavelength) * blackBodyLuminance / relativeLuminance

  @getRelativeEmissionSpectrumForCorrelatedColorTemperature: (correlatedColorTemperature) ->
    T = correlatedColorTemperature

    if 4000 <= T <= 7000
      xᴅ = 0.244063 + 0.09911e3 / T + 2.9678e6 / T ** 2 - 4.607e9 / T ** 3

    else if 7000 < T < 25000
      xᴅ = 0.23704 + 0.24748e3 / T + 1.9018e6 / T ** 2 - 2.0064e9 / T ** 3

    else
      console.warn "D series is not defined outside the 4000–25000 K interval."
      return null

    yᴅ = -3 * xᴅ ** 2 + 2.87 * xᴅ - 0.275

    M = 0.0241 + 0.2562 * xᴅ - 0.7341 * yᴅ
    M1 = (-1.351 - 1.7703 * xᴅ + 5.9114 * yᴅ) / M
    M2 = (0.03 - 31.4424 * xᴅ + 30.0717 * yᴅ) / M

    D = @

    # Return spectral radiance in W / sr⋅m³
    new AR.Optics.Spectrum.Formulated (wavelength) ->
      wavelengthNanometers = wavelength * 1e9

      S0 = D.s0 wavelengthNanometers
      S1 = D.s1 wavelengthNanometers
      S2 = D.s2 wavelengthNanometers

      S0 + M1 * S1 + M2 * S2

  @s0: (wavelengthNanometers) -> @_interpolateTable 1, wavelengthNanometers
  @s1: (wavelengthNanometers) -> @_interpolateTable 2, wavelengthNanometers
  @s2: (wavelengthNanometers) -> @_interpolateTable 3, wavelengthNanometers

  @_interpolateTable: (column, wavelengthNanometers) ->
    fractionalRow = (wavelengthNanometers - 300) / 5

    middleRowIndex = _.clamp Math.round(fractionalRow), 1, @table.length - 2

    rows = [
      @table[middleRowIndex - 1]
      @table[middleRowIndex]
      @table[middleRowIndex + 1]
    ]

    x = (wavelengthNanometers - rows[0][0]) / 5

    # The tabulated data doesn't provide valid values outside the tabulated range.
    return 0 unless 0 <= x <= 2

    y1 = rows[0][column]
    y2 = rows[1][column]
    y3 = rows[2][column]

    a = (y3 - 2 * y2 + y1) / 2
    b = (y3 - 4 * y2 + 3 * y1) / -2
    c = y1

    value = a * x * x + b * x + c

    Math.max 0, value
