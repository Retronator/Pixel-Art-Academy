AP = Artificial.Pyramid
AR = Artificial.Reality

class AR.Optics.Scattering
  @getRayleighCrossSectionFunction: ->
    unless @_rayleighCrossSectionFunction
      # 8π³(n²-1)²
      # ---------- * Fk
      #   3N²λ⁴
      factor = 8 * (Math.PI ** 3) / 3

      @_rayleighCrossSectionFunction = (refractiveIndex, molecularNumberDensity, wavelength, kingCorrectionFactor = 1) ->
        # Avoid boundary conditions.
        return 0 unless molecularNumberDensity

        factor * (refractiveIndex ** 2 - 1) ** 2 / (molecularNumberDensity ** 2 * wavelength ** 4) * kingCorrectionFactor

    @_rayleighCrossSectionFunction

  @getRayleighCoefficientFunction: ->
    unless @_rayleighCoefficientFunction
      # β = σn
      rayleighCrossSectionFunction = @getRayleighCrossSectionFunction()

      @_rayleighCoefficientFunction = (refractiveIndex, molecularNumberDensity, wavelength, kingCorrectionFactor) ->
        # Avoid boundary conditions.
        return 0 unless molecularNumberDensity

        rayleighCrossSectionFunction(refractiveIndex, molecularNumberDensity, wavelength, kingCorrectionFactor) * molecularNumberDensity

    @_rayleighCoefficientFunction

  @getRayleighPhaseFunction: ->
    unless @_rayleighPhaseFunction
      normalizationFactor = 3 / (16 * Math.PI)

      @_rayleighPhaseFunction = (scatteringAngle) ->
        normalizationFactor * (1 + Math.cos(scatteringAngle) ** 2)

    @_rayleighPhaseFunction
