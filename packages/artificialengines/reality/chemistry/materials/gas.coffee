AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Chemistry.Materials.Gas extends AR.Chemistry.Materials.Material
  @initialize: (@options) ->
    super arguments...

    if @options.dispersion
      # Prepare refractive index function based on the supplied dispersion coefficients.
      #                     Bᵢ
      # n(λ) = 1 + A + ∑ --------
      #                ᵢ Cᵢ - λ⁻²
      A = @options.dispersion.coefficients[0]
      B = []
      C = []

      for i in [1...@options.dispersion.coefficients.length] by 2
        B.push @options.dispersion.coefficients[i]
        C.push @options.dispersion.coefficients[i + 1]

      @_refractiveIndexSpectrum = (wavelength) ->
        wavelengthFactor = (wavelength * 1e6) ** (-2)

        result = 1 + A
        result += B[i] / (C[i] - wavelengthFactor) for i in [0...B.length]
        result

    if @options.kingCorrectionFactorCoefficients
      # Prepare king correction factor function.
      #              F₂   F₃
      # Fk(λ) = F₁ + -- + --
      #              λ²   λ⁴
      F1 = @options.kingCorrectionFactorCoefficients[0]
      F2 = @options.kingCorrectionFactorCoefficients[1]
      F3 = @options.kingCorrectionFactorCoefficients[2]

      @_kingCorrectionFactorSpectrum = (wavelength) ->
        wavelengthSquared = wavelength ** 2
        result = F1 + F2 / wavelengthSquared
        return result unless F3

        result + F3 / wavelengthSquared ** 2

  @getRefractiveIndexSpectrum: ->
    # Return refractive index at standard temperature and pressure
    @getRefractiveIndexSpectrumForState
      temperature: AR.StandardTemperatureAndPressure.Temperature
      pressure: AR.StandardTemperatureAndPressure.Pressure

  @getKingCorrectionFactorSpectrum: -> @_kingCorrectionFactorSpectrum

  @getRefractiveIndexSpectrumForState: (state) ->
    temperatureRatio = @options.dispersion.temperature / state.temperature
    pressureRatio = state.pressure / @options.dispersion.pressure

    refractiveIndexSpectrum = @_refractiveIndexSpectrum

    (wavelength) ->
      refractiveIndex = refractiveIndexSpectrum wavelength

      # Derived by assuming constant molar refractivity.
      Math.sqrt 1 + temperatureRatio * pressureRatio * (refractiveIndex ** 2 - 1)
