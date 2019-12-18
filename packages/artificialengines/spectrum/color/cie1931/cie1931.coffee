AS = Artificial.Spectrum
AP = Artificial.Pyramid

class AS.Color.CIE1931
  @_minWavelength = 380e-9
  @_maxWavelength = 780e-9
  @_wavelengthSpacing = 5e-9

  @getRelativeXYZForWavelength: (wavelength) ->
    wavelengthNanometers = wavelength * 1e9

    x: @ColorMatchingFunctions.x wavelengthNanometers
    y: @ColorMatchingFunctions.y wavelengthNanometers
    z: @ColorMatchingFunctions.z wavelengthNanometers

  @getXYZForSpectrum: (spectrum) ->
    xyz = {}

    for coordinate in ['x', 'y', 'z']
      xyz[coordinate] = AP.Integration.integrateWithMidpointRule (wavelength) =>
        @ColorMatchingFunctions[coordinate](wavelength * 1e9) * spectrum(wavelength)
      ,
        @_minWavelength, @_maxWavelength, @_wavelengthSpacing

    xyz

  @getLuminanceForSpectrum: (spectrum) ->
    AP.Integration.integrateWithMidpointRule (wavelength) =>
      @ColorMatchingFunctions.y(wavelength * 1e9) * spectrum(wavelength)
    ,
      @_minWavelength, @_maxWavelength, @_wavelengthSpacing

  @getChromaticityForXYZ: (xyz) ->
    sum = xyz.x + xyz.y + xyz.z

    x: xyz.x / sum
    y: xyz.y / sum

  @getChromaticityForWavelength: (wavelength) ->
    @getChromaticityForXYZ @getRelativeXYZForWavelength wavelength
