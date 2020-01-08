AP = Artificial.Pyramid
AR = Artificial.Reality

class AR.Optics.Scattering
  @getRayleighCrossSectionFunction: ->
    unless @_rayleighCrossSectionFunction
      # 32π³(n-1)²
      # -----------
      #    3N₀²λ⁴
      factor = 32 * (Math.PI ** 3) / (3 * AR.LoschmidtConstant ** 2)

      @_rayleighCrossSectionFunction = (refractiveIndex, wavelength) ->
        factor * (refractiveIndex - 1) ** 2 / wavelength ** 4

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
