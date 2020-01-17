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
        factor * (refractiveIndex ** 2 - 1) ** 2 / (molecularNumberDensity ** 2 * wavelength ** 4) * kingCorrectionFactor

    @_rayleighCrossSectionFunction

  @getRayleighCoefficientFunction: ->
    unless @_rayleighCoefficientFunction
      rayleighCrossSectionFunction = @getRayleighCrossSectionFunction()

      @_rayleighCoefficientFunction = (refractiveIndex, wavelength, molecularConcentration) ->
        # β = σn
        rayleighCrossSectionFunction(refractiveIndex, wavelength) * molecularConcentration

    @_rayleighCoefficientFunction

  getRayleighPhaseFunction: ->
    unless @_rayleighPhaseFunction
      normalizationFactor = 3 / (16 * Math.PI)

      @_rayleighPhaseFunction = (scatteringAngle) ->
        normalizationFactor * (1 + Math.cos(scatteringAngle) ** 2)

    @_rayleighPhaseFunction
