AS = Artificial.Spectrum
AP = Artificial.Pyramid

class AS.Color.CIE1931
  @_minWavelength = 380e-9
  @_maxWavelength = 780e-9
  @_wavelengthSpacing = 5e-9

  @getRelativeXYZForWavelength: (wavelength) ->
    x: @ColorMatchingFunctions.x.getValue wavelength
    y: @ColorMatchingFunctions.y.getValue wavelength
    z: @ColorMatchingFunctions.z.getValue wavelength

  @getXYZForSpectrum: (spectrum, wavelengthSpacing = @_wavelengthSpacing) ->
    xyz = {}

    for coordinate in ['x', 'y', 'z']
      colorMatchingFunction = @ColorMatchingFunctions[coordinate]

      if colorMatchingFunction.matchesType spectrum
        xyz[coordinate] = @_integrateFast colorMatchingFunction, spectrum

      else
        xyz[coordinate] = AP.Integration.integrateWithMidpointRule (wavelength) =>
          colorMatchingFunction.getValue(wavelength) * spectrum.getValue(wavelength)
        ,
          @_minWavelength, @_maxWavelength, wavelengthSpacing

    xyz

  @_integrateFast: (colorMatchingFunction, spectrum) ->
    sum = 0

    for value, index in colorMatchingFunction.array
      sum += value * spectrum.array[index] * colorMatchingFunction.options.wavelengthSpacing

    sum

  @getLuminanceForSpectrum: (spectrum) ->
    if @ColorMatchingFunctions.y.matchesType spectrum
      xyz[coordinate] = @_integrateFast @ColorMatchingFunctions.y, spectrum

    else
      AP.Integration.integrateWithMidpointRule (wavelength) =>
        @ColorMatchingFunctions.y.getValue(wavelength) * spectrum.getValue(wavelength)
      ,
        @_minWavelength, @_maxWavelength, @_wavelengthSpacing

  @getChromaticityForXYZ: (xyz) ->
    sum = xyz.x + xyz.y + xyz.z

    x: xyz.x / sum
    y: xyz.y / sum

  @getChromaticityForWavelength: (wavelength) ->
    @getChromaticityForXYZ @getRelativeXYZForWavelength wavelength
