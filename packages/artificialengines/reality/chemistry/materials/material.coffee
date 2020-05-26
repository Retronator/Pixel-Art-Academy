AE = Artificial.Everywhere
AR = Artificial.Reality

class AR.Chemistry.Materials.Material
  @id: -> throw new AE.NotImplementedException 'Material must have an ID.'

  @displayName: -> null # Override to provide a name of the material.
  @formula: -> null # Override to provide a chemical formula of the material.

  @initialize: ->
    AR.Chemistry.Materials.registerMaterial @

  @getRefractiveIndexSpectrum: -> throw new AE.NotImplementedException "Material must provide a function of refractive index per wavelength."

  @getExtinctionCoefficientSpectrum: -> null # Override to provide a function of k per wavelength. 0 is assumed otherwise.

  @getEmissionSpectrumForTemperature: (temperature, angleOfIncidence = 0) ->
    blackBodySpectrum = AR.Optics.LightSources.BlackBody.getEmissionSpectrumForTemperature temperature

    refractiveIndexSpectrum = @getRefractiveIndexSpectrum()
    extinctionCoefficientSpectrum = @getExtinctionCoefficientSpectrum()

    absorptanceSpectrum = new AR.Optics.Spectrum.Formulated (wavelength) ->
      refractiveIndex = refractiveIndexSpectrum.getValue wavelength
      extinctionCoefficient = extinctionCoefficientSpectrum?.getValue(wavelength) or 0

      AR.Optics.FresnelEquations.getAbsorptance angleOfIncidence, 1, refractiveIndex, 0, extinctionCoefficient

    # Return radiance in W / sr⋅m³
    new AR.Optics.Spectrum.Formulated (wavelength) ->
      emissivity = absorptanceSpectrum.getValue wavelength
      blackBodySpectrum.getValue(wavelength) * emissivity
