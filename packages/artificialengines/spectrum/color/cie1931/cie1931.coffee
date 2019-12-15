AS = Artificial.Spectrum
AP = Artificial.Pyramid

class AS.Color.CIE1931
  @getXYZForWavelength: (wavelength) ->
    wavelengthNanometers = wavelength * 1e9

    x: @ColorMatchingFunctions.x wavelengthNanometers
    y: @ColorMatchingFunctions.y wavelengthNanometers
    z: @ColorMatchingFunctions.z wavelengthNanometers

  @getXYZForSpectrum: (spectrumFunction) ->
    minWavelengthNanometers = 380
    maxWavelengthNanometers = 780
    wavelengthSpacingNanometers = 10

    x = AP.Integration.integrateWithMidpointRule (wavelengthNanometers) =>
      @ColorMatchingFunctions.x(wavelengthNanometers) * spectrumFunction(wavelengthNanometers / 1e9)
    ,
      minWavelengthNanometers, maxWavelengthNanometers, wavelengthSpacingNanometers

    y = AP.Integration.integrateWithMidpointRule (wavelengthNanometers) =>
      @ColorMatchingFunctions.x(wavelengthNanometers) * spectrumFunction(wavelengthNanometers / 1e9)
    ,
      minWavelengthNanometers, maxWavelengthNanometers, wavelengthSpacingNanometers

    z = AP.Integration.integrateWithMidpointRule (wavelengthNanometers) =>
      @ColorMatchingFunctions.x(wavelengthNanometers) * spectrumFunction(wavelengthNanometers / 1e9)
    ,
      minWavelengthNanometers, maxWavelengthNanometers, wavelengthSpacingNanometers

    {x, y, z}

  @getChromaticityForXYZ: (xyz) ->
    sum = xyz.x + xyz.y + xyz.z

    x: xyz.x / sum
    y: xyz.y / sum

  @getChromaticityForWavelength: (wavelength) ->
    @getChromaticityForXYZ @getXYZForWavelength wavelength
