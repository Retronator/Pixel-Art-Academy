AE = Artificial.Everywhere
AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Optics.LightSources.LightSource
  @correlatedColorTemperature: -> null # Override to be able to provide the emission spectrum at the specified CCT.

  @getEmissionSpectrum: ->
    return unless correlatedColorTemperature = _.propertyValue @, 'correlatedColorTemperature'

    blackBodySpectrum = AR.Optics.LightSources.BlackBody.getEmissionSpectrumForTemperature correlatedColorTemperature
    blackBodyLuminance = Artificial.Spectrum.Color.XYZ.getLuminanceForSpectrum blackBodySpectrum

    @getEmissionSpectrumForLuminance blackBodyLuminance

  @getEmissionSpectrumForLuminance: (luminance) ->
    return unless relativeEmissionSpectrum = @getRelativeEmissionSpectrum()
    return unless relativeLuminance = @relativeLuminance or @getRelativeLuminance()

    # Return radiance in W / sr⋅m³
    new AR.Optics.Spectrum.Formulated (wavelength) -> relativeEmissionSpectrum.getValue(wavelength) * luminance / relativeLuminance

  @getRelativeLuminance: ->
    return unless relativeEmissionSpectrum = @getRelativeEmissionSpectrum()

    Artificial.Spectrum.Color.XYZ.getLuminanceForSpectrum relativeEmissionSpectrum

  @getRelativeEmissionSpectrum: -> null # Override to provide a relative emission spectrum.
