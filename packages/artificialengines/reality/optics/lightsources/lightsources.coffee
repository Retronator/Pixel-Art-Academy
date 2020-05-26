AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Optics.LightSources
  @getRadianceForEmissionSpectrum: (spectrum, minWavelength = 0, maxWavelength = 1e-2, minimumSpacing = 5e-9) ->
    # Integrate the spectrum, by default in the region from 0 to 1cm wavelengths in 5nm intervals.
    AP.Integration.integrateWithMidpointRule spectrum, minWavelength, maxWavelength, minimumSpacing
