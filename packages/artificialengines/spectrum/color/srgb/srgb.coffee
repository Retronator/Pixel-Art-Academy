AS = Artificial.Spectrum
AR = Artificial.Reality

class AS.Color.SRGB
  @NormalizedXYZtoLinearRGBTransform = new THREE.Matrix3().set(
    3.2406, -1.5372, -0.4986,
    -0.9689, 1.8758, 0.0415,
    0.0557, -0.204, 1.057
  )

  @LinearRGBToNormalizedXYZTransform = new THREE.Matrix3().set(
    0.4124, 0.3576, 0.1805,
    0.2126, 0.7152, 0.0722,
    0.0193, 0.1192, 0.9505
  )

  @xyzNormalizationFactor = 2.2178461498317438e-7 # Calculated with getXYZNormalizationFactor method and cached for speed.

  @getXYZNormalizationFactor: ->
    # We want to normalize XYZ values such that Y is 1 for the D65 spectrum.
    d65Spectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()
    1 / AS.Color.CIE1931.getYForSpectrum d65Spectrum

  @getNormalizedXYZForXYZ: (xyz) ->
    new THREE.Vector3().copy(xyz).multiplyScalar(@xyzNormalizationFactor)

  @getLinearRGBForXYZ: (xyz) ->
    @getLinearRGBForNormalizedXYZ @getNormalizedXYZForXYZ xyz

  @getLinearRGBForNormalizedXYZ: (xyz) ->
    rgbVector = new THREE.Vector3().copy(xyz).applyMatrix3 @NormalizedXYZtoLinearRGBTransform

    r: rgbVector.x
    g: rgbVector.y
    b: rgbVector.z

  @getXYZForLinearRGB: (linearRGB) ->
    @getXYZForNormalizedXYZ @getNormalizedXYZForLinearRGB(linearRGB)

  @getNormalizedXYZForLinearRGB: (linearRGB) ->
    new THREE.Vector3(linearRGB.r, linearRGB.g, linearRGB.b).applyMatrix3(@LinearRGBToNormalizedXYZTransform)

  @getXYZForNormalizedXYZ: (xyz) ->
    new THREE.Vector3().copy(xyz).multiplyScalar(1 / @xyzNormalizationFactor)

  @getRGBForLinearRGB: (linearRGB) ->
    r: @gamma linearRGB.r
    g: @gamma linearRGB.g
    b: @gamma linearRGB.b

  @getRGBForXYZ: (xyz) ->
    @getRGBForLinearRGB @getLinearRGBForXYZ xyz

  @gamma: (value) ->
    if value <= 0.0031308 then 323 * value / 25 else (211 * Math.pow(value, 5 / 12) - 11) / 200

  @getLinearRGBForRGB: (rgb) ->
    r: @gammaInverse rgb.r
    g: @gammaInverse rgb.g
    b: @gammaInverse rgb.b

  @gammaInverse: (value) ->
    if value <= 0.04045 then 25 * value / 323 else Math.pow((200 * value + 11) / 211, 12 / 5)
