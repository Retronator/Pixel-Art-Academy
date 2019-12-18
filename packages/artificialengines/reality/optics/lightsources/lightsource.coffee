AE = Artificial.Everywhere
AR = Artificial.Reality
AP = Artificial.Pyramid
AS = Artificial.Spectrum

class AR.Optics.LightSources.LightSource
  @correlatedColorTemperature: -> null # Override to be able to provide the emission spectrum at the specified CCT.

  @getEmissionSpectrum: ->
    return unless correlatedColorTemperature = _.propertyValue @, 'correlatedColorTemperature'

    blackBodySpectrum = AR.Optics.LightSources.BlackBody.getEmissionSpectrumForTemperature correlatedColorTemperature
    blackBodyLuminance = AS.Color.CIE1931.getLuminanceForSpectrum blackBodySpectrum

    @getEmissionSpectrumForLuminance blackBodyLuminance

  @getEmissionSpectrumForLuminance: (luminance) ->
    return unless relativeEmissionSpectrum = @getRelativeEmissionSpectrum()
    return unless relativeLuminance = @relativeLuminance or @getRelativeLuminance()

    # Return radiance in W / sr⋅m³
    (wavelength) -> relativeEmissionSpectrum(wavelength) * luminance / relativeLuminance

  @getRelativeLuminance: ->
    return unless relativeEmissionSpectrum = @getRelativeEmissionSpectrum()

    AS.Color.CIE1931.getLuminanceForSpectrum relativeEmissionSpectrum

  @getRelativeEmissionSpectrum: -> null # Override to provide a relative emission spectrum.
