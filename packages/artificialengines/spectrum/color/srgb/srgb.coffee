AS = Artificial.Spectrum
AR = Artificial.Reality

class AS.Color.SRGB
  @XYZtoRGBTransform = new THREE.Matrix3().set(
    3.2406, -1.5372, -0.4986,
    -0.9689, 1.8758, 0.0415,
    0.0557, -0.204, 1.057
  )

  @RGBToXYZTransform = new THREE.Matrix3().set(
    0.4124, 0.3576, 0.1805,
    0.2126, 0.7152, 0.0722,
    0.0193, 0.1192, 0.9505
  )

  # Store the D65 illuminant as a sampled spectrum for quick calculations.
  @d65Illuminant = new AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5()

  Meteor.startup =>
    @d65Illuminant.copy AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()

  @xyzNormalizationFactor = 2.2178461498317438e-7 # Calculated with getXYZNormalizationFactor method and cached for speed.

  @getXYZNormalizationFactor: ->
    # We want to normalize XYZ values such that Y is 1 for the D65 spectrum.
    d65Spectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()
    1 / AS.Color.CIE1931.getYForSpectrum d65Spectrum

  # Spectrum -> RGB
  @getRGBFactorsForSpectrum: (spectrum) ->
    normalizedXYZ = Artificial.Spectrum.Color.XYZ.getXYZFactorsForSpectrum spectrum, @d65Illuminant
    @getRGBForXYZ normalizedXYZ

  # XYZ -> RGB

  @getNormalizedXYZForXYZ: (xyz) ->
    new THREE.Vector3().copy(xyz).multiplyScalar(@xyzNormalizationFactor)

  @getNormalizedRGBForXYZ: (xyz) ->
    @getRGBForXYZ @getNormalizedXYZForXYZ xyz

  @getRGBForXYZ: (xyz) ->
    rgbVector = new THREE.Vector3().copy(xyz).applyMatrix3 @XYZtoRGBTransform

    r: rgbVector.x
    g: rgbVector.y
    b: rgbVector.z

  # RGB -> XYZ

  @getXYZForNormalizedRGB: (linearRGB) ->
    @getXYZForNormalizedXYZ @getXYZForRGB linearRGB

  @getXYZForRGB: (linearRGB) ->
    new THREE.Vector3(linearRGB.r, linearRGB.g, linearRGB.b).applyMatrix3(@RGBToXYZTransform)

  @getXYZForNormalizedXYZ: (xyz) ->
    new THREE.Vector3().copy(xyz).multiplyScalar(1 / @xyzNormalizationFactor)

  # Gamma

  @getGammaRGBForNormalizedRGB: (linearRGB) ->
    r: @gamma linearRGB.r
    g: @gamma linearRGB.g
    b: @gamma linearRGB.b

  @getGammaRGBForXYZ: (xyz) ->
    @getGammaRGBForNormalizedRGB @getNormalizedRGBForXYZ xyz

  @gamma: (value) ->
    if value <= 0.0031308 then 323 * value / 25 else (211 * Math.pow(value, 5 / 12) - 11) / 200

  @getNormalizedRGBForGammaRGB: (rgb) ->
    r: @gammaInverse rgb.r
    g: @gammaInverse rgb.g
    b: @gammaInverse rgb.b

  @gammaInverse: (value) ->
    if value <= 0.04045 then 25 * value / 323 else Math.pow((200 * value + 11) / 211, 12 / 5)
