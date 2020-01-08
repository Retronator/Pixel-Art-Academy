AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Chemistry.Materials.Gas extends AR.Chemistry.Materials.Material
  @initialize: (@options) ->
    super arguments...

    # Prepare refractive index function based on the supplied dispersion coefficients.
    #                    B
    # n(λ) = 1 + A + -------
    #                 C - λ⁻²
    A = @options.dispersion.coefficients[0]
    B = @options.dispersion.coefficients[1]
    C = @options.dispersion.coefficients[2]

    @_refractiveIndexSpectrum = (wavelength) ->
      1 + A + B / (C - (wavelength * 1e6) ** (-2))

    # Calculate molar volume at standard temperature and pressure (STP).
    @StandardMolarVolume = @options.standardMolarVolume if @options.standardMolarVolume

    # Calculate derived properties.
    @StandardMolarConcentration = 1 / @StandardMolarVolume
    @StandardMolecularConcentration = @StandardMolarConcentration * AR.AvogadroNumber

  @getRefractiveIndexSpectrum: ->
    # Return refractive index at standard temperature and pressure
    @getRefractiveIndexSpectrumForState
      temperature: AR.StandardTemperatureAndPressure.Temperature
      pressure: AR.StandardTemperatureAndPressure.Pressure

  @getRefractiveIndexSpectrumForState: (state) ->
    T = state.temperature
    p = state.pressure

    T0 = @options.dispersion.temperature
    p0 = @options.dispersion.pressure

    refractiveIndexSpectrum = @_refractiveIndexSpectrum

    (wavelength) ->
      n0 = refractiveIndexSpectrum wavelength

      Math.sqrt 1 + T0 / T * p0 / p * (n0 ** 2 - 1)
