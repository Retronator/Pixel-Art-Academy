AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Chemistry.Materials.Mixtures.Glass extends AR.Chemistry.Materials.Material
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

    # Prepare refractive index function based on the supplied coefficients.
    sellmeierCoefficients = (parseFloat value for value in options.sellmeierCoefficients.split ' ')

    #               B₁λ²      B₂λ²     B₃λ²
    # n²(λ) = 1 + ------- + ------- + -------
    #             λ² - C₁   λ² - C₂   λ² - C₃

    B = [0, sellmeierCoefficients[1], sellmeierCoefficients[3], sellmeierCoefficients[5]]
    C = [0, sellmeierCoefficients[2], sellmeierCoefficients[4], sellmeierCoefficients[6]]

    @_refractiveIndexSpectrum = new AR.Optics.Spectrum.Formulated (wavelength) ->
      x = (wavelength * 1e6) ** 2

      Math.sqrt 1 + B[1] / (1 - C[1] / x) + B[2] / (1 - C[2] / x) + B[3] / (1 - C[3] / x)

  @getRefractiveIndexSpectrum: -> @_refractiveIndexSpectrum
  @getExtinctionCoefficientSpectrum: -> @_extinctionCoefficientSpectrum
