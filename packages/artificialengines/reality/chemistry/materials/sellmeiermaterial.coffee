AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Chemistry.Materials.SellmeierMaterial extends AR.Chemistry.Materials.Material
  @initialize: (options) ->
    super arguments...

    # Prepare refractive index function based on the supplied coefficients.
    sellmeierCoefficients = (parseFloat value for value in options.sellmeierCoefficients.split ' ')
    #                 Bᵢλ²
    # n²(λ) = 1 + ∑ -------
    #               λ² - Cᵢ
    B = []
    C = []

    for i in [1...sellmeierCoefficients.length] by 2
      B.push sellmeierCoefficients[i]
      C.push sellmeierCoefficients[i + 1]

    @_refractiveIndexSpectrum = new AR.Optics.Spectrum.Formulated (wavelength) ->
      x = (wavelength * 1e6) ** 2

      sum = 1
      sum += B[i] / (1 - C[i] / x) for i in [0...B.length]
      Math.sqrt sum

  @getRefractiveIndexSpectrum: -> @_refractiveIndexSpectrum
