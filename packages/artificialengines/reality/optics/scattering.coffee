AP = Artificial.Pyramid
AR = Artificial.Reality

class AR.Optics.Scattering
  @getRayleighCoefficientFunction: ->
    unless @_rayleighCoefficientFunction
      # 8π³(n²-1)²
      # ----------
      #    3Nλ⁴
      factor = 8 * (Math.PI ** 3) / 3

      @_rayleighCoefficientFunction = (refractiveIndex, wavelength, molecularConcentration) ->
        (factor * (refractiveIndex ** 2 - 1) ** 2) / (molecularConcentration * wavelength ** 4)

    @_rayleighCoefficientFunction

  getRayleighPhaseFunction: ->
    unless @_rayleighPhaseFunction
      normalizationFactor = 3 / (16 * Math.PI)

      @_rayleighPhaseFunction = (scatteringAngle) ->
        normalizationFactor * (1 + Math.cos(scatteringAngle) ** 2)

    @_rayleighPhaseFunction
