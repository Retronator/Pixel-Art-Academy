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
      sum += value * spectrum.array[index]

    sum * colorMatchingFunction.options.wavelengthSpacing

  # Returns XYZ factors, i.e. multipliers that will change an XYZ spectrum as much as the spectrum
  # would (e.g. a spectrum with all values 0.5 will give an XYZ response of 0.5 in all coordinates).
  @getXYZFactorsForSpectrum: (spectrum) ->
    xyz = {}

    readFromArray = @ColorMatchingFunctions.x.matchesType spectrum

    for coordinate in ['x', 'y', 'z']
      colorMatchingFunction = @ColorMatchingFunctions[coordinate]
      sum = 0

      for value, index in colorMatchingFunction.array
        response = if readFromArray then spectrum.array[index] else spectrum.getValue @_minWavelength + index * @_wavelengthSpacing
        sum += value * response

      # Set normalized factor.
      xyz[coordinate] = sum / @ColorMatchingFunctions.integrals[coordinate]

    xyz

  @getYForSpectrum: (spectrum) ->
    if @ColorMatchingFunctions.y.matchesType spectrum
      @_integrateFast @ColorMatchingFunctions.y, spectrum

    else
      AP.Integration.integrateWithMidpointRule (wavelength) =>
        @ColorMatchingFunctions.y.getValue(wavelength) * spectrum.getValue(wavelength)
      ,
        @_minWavelength, @_maxWavelength, @_wavelengthSpacing

  @getLuminanceForSpectrum: (spectrum) ->
    # Return luminance in cd/m².
    @getLuminanceForY @getYForSpectrum(spectrum)

  @getLuminanceForXYZ: (xyz) ->
    @getLuminanceForY xyz.y

  @getLuminanceForY: (y) ->
    # Return luminance in cd/m².
    y * 683.002

  @getChromaticityForXYZ: (xyz) ->
    sum = xyz.x + xyz.y + xyz.z

    x: xyz.x / sum
    y: xyz.y / sum

  @getChromaticityForWavelength: (wavelength) ->
    @getChromaticityForXYZ @getRelativeXYZForWavelength wavelength
