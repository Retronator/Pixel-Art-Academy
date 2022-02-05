AS = Artificial.Spectrum
AP = Artificial.Pyramid

class AS.Color.Conversion
  @getCoordinatesForSpectrum: (spectrum, wavelengthProperties, colorMatchingFunctions) ->
    coordinates = {}

    for coordinate, colorMatchingFunction of colorMatchingFunctions
      if colorMatchingFunction.matchesType spectrum
        coordinates[coordinate] = @integrateFast colorMatchingFunction, spectrum

      else
        coordinates[coordinate] = AP.Integration.integrateWithMidpointRule (wavelength) =>
          colorMatchingFunction.getValue(wavelength) * spectrum.getValue(wavelength)
        ,
          wavelengthProperties.minimum, wavelengthProperties.maximum, wavelengthProperties.spacing

    coordinates

  @integrateFast: (colorMatchingFunction, spectrum) ->
    sum = 0

    for value, index in colorMatchingFunction.array
      sum += value * spectrum.array[index]

    sum * colorMatchingFunction.options.wavelengthSpacing

  # Returns factors, i.e. multipliers that will change a coordinate spectrum as much as the spectrum
  # would (e.g. a spectrum with all values 0.5 will give a response of 0.5 in all coordinates).
  @getCoordinateFactorsForSpectrumOld: (spectrum, wavelengthProperties, colorMatchingFunctions, colorMatchingFunctionIntegrals) ->
    coordinates = {}

    for coordinate, colorMatchingFunction of colorMatchingFunctions
      readFromArray = colorMatchingFunction.matchesType spectrum
      sum = 0

      for value, index in colorMatchingFunction.array
        response = if readFromArray then spectrum.array[index] else spectrum.getValue wavelengthProperties.minimum + index * wavelengthProperties.spacing
        sum += value * response

      # Set normalized factor.
      coordinates[coordinate] = sum / colorMatchingFunctionIntegrals[coordinate]

    coordinates

  @getCoordinateFactorsForSpectrum: (spectrum, wavelengthProperties, colorMatchingFunctions, normalizationFunction, referenceIlluminant) ->
    coordinates = {}

    # Determine normalization factor.
    normalizationDivisor = 0
    readIlluminantFromArray = normalizationFunction.matchesType referenceIlluminant

    for value, index in normalizationFunction.array
      illuminantResponse = if readIlluminantFromArray then referenceIlluminant.array[index] else referenceIlluminant.getValue wavelengthProperties.minimum + index * wavelengthProperties.spacing
      normalizationDivisor += value * illuminantResponse

    # Determine coordinates.
    for coordinate, colorMatchingFunction of colorMatchingFunctions
      readSpectrumFromArray = colorMatchingFunction.matchesType spectrum
      sum = 0

      for value, index in colorMatchingFunction.array
        illuminantResponse = if readIlluminantFromArray then referenceIlluminant.array[index] else referenceIlluminant.getValue wavelengthProperties.minimum + index * wavelengthProperties.spacing
        spectrumResponse = if readSpectrumFromArray then spectrum.array[index] else spectrum.getValue wavelengthProperties.minimum + index * wavelengthProperties.spacing
        sum += value * illuminantResponse * spectrumResponse

      # Set normalized factor.
      coordinates[coordinate] = sum / normalizationDivisor

    coordinates
