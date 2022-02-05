AS = Artificial.Spectrum
AP = Artificial.Pyramid

class AS.Color.XYZ
  @_wavelengthProperties:
    minimum: 380e-9
    maximum: 780e-9
    spacing: 5e-9

  @getColorMatchingFunctions: ->
    @_colorMatchingFunctions ?= _.pick @ColorMatchingFunctions, ['x', 'y', 'z']
    @_colorMatchingFunctions

  @getRelativeXYZForWavelength: (wavelength) ->
    x: @ColorMatchingFunctions.x.getValue wavelength
    y: @ColorMatchingFunctions.y.getValue wavelength
    z: @ColorMatchingFunctions.z.getValue wavelength

  @getXYZForSpectrum: (spectrum, wavelengthSpacing) ->
    wavelengthProperties = _.defaults
      spacing: wavelengthSpacing
    ,
      @_wavelengthProperties

    AS.Color.Conversion.getCoordinatesForSpectrum spectrum, wavelengthProperties, @getColorMatchingFunctions()

  @getXYZFactorsForSpectrum: (spectrum, referenceIlluminant) ->
    AS.Color.Conversion.getCoordinateFactorsForSpectrum spectrum, @_wavelengthProperties, @getColorMatchingFunctions(), @ColorMatchingFunctions.y, referenceIlluminant

  @getYForSpectrum: (spectrum) ->
    if @ColorMatchingFunctions.y.matchesType spectrum
      AS.Color.Conversion.integrateFast @ColorMatchingFunctions.y, spectrum

    else
      AP.Integration.integrateWithMidpointRule (wavelength) =>
        @ColorMatchingFunctions.y.getValue(wavelength) * spectrum.getValue(wavelength)
      ,
        @_wavelengthProperties.minimum, @_wavelengthProperties.maximum, @_wavelengthProperties.spacing

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

  @xyzNormalizationFactor = 2.2178461498317438e-7 # Calculated with getXYZNormalizationFactor method and cached for speed.

  @getXYZNormalizationFactor: ->
    # We want to normalize XYZ values such that Y is 1 for the D65 spectrum.
    d65Spectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()
    1 / AS.Color.XYZ.getYForSpectrum d65Spectrum

  # XYZ -> RGB

  @getNormalizedXYZForXYZ: (xyz) ->
    new THREE.Vector3().copy(xyz).multiplyScalar(@xyzNormalizationFactor)