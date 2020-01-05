AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Chemistry.Materials.Gas extends AR.Chemistry.Materials.Material
  @initialize: (options) ->
    super arguments...

    # Prepare refractive index function based on the supplied coefficients. We use a modified Sellmeier equation.
    sellmeierCoefficients = (parseFloat value for value in options.sellmeierCoefficients.split ' ')

    #                    B
    # n²(λ) = 1 + A + -------
    #                 C - λ⁻²
    A = sellmeierCoefficients[1]
    B = sellmeierCoefficients[2]
    C = sellmeierCoefficients[3]

    @_refractiveIndexSpectrum = (wavelength) ->
      Math.sqrt 1 + A + B / (C - (wavelength * 1e6) ** (-2))

    # Calculate molar volume at standard temperature and pressure (STP).
    @StandardMolarVolume = options.standardMolarVolume if options.standardMolarVolume

    # Calculate derived properties.
    @StandardMolarConcentration = 1 / @StandardMolarVolume
    @StandardMolecularConcentration = @StandardMolarConcentration * AR.AvogadroNumber

  @getRefractiveIndexSpectrum: -> @_refractiveIndexSpectrum
