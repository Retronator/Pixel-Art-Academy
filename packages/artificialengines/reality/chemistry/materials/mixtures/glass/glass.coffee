AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Chemistry.Materials.Mixtures.Glass extends AR.Chemistry.Materials.SellmeierMaterial
  @initialize: (options) ->
    super arguments...

    rows = options.table.split '\n'

    extinctionCoefficients = []

    for row in rows
      values = row.split ' '
      wavelengthMicrometers = parseFloat values[0]
      wavelength = wavelengthMicrometers / 1e6

      extinctionCoefficientCentimeters = parseFloat values[1]
      extinctionCoefficient = extinctionCoefficientCentimeters * 1e2
      extinctionCoefficients.push {wavelength, value: extinctionCoefficient}

    # Create the linearly interpolated function to query the extinction coefficient at any x.
    @_extinctionCoefficientSpectrum = new AR.Optics.Spectrum.Sampled extinctionCoefficients if extinctionCoefficients

  @getExtinctionCoefficientSpectrum: -> @_extinctionCoefficientSpectrum
