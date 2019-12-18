AS = Artificial.Spectrum
AR = Artificial.Reality

class AS.Color.SRGB
  @XYZtoLinearRGBTransform = new THREE.Matrix3().set(
    3.2406, -1.5372, -0.4986,
    -0.9689, 1.8758, 0.0415,
    0.0557, -0.204, 1.057
  )

  @LinearRGBToXYZTransform = new THREE.Matrix3().set(
    0.4124, 0.3576, 0.1805,
    0.2126, 0.7152, 0.0722,
    0.0193, 0.1192, 0.9505
  )

  @d65LuminanceFactor = 4508707.775774763 # Calculated with getD65LuminanceFactor method and cached for speed.

  @getD65LuminanceFactor: ->
    d65Spectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()
    AS.Color.CIE1931.getLuminanceForSpectrum d65Spectrum

  @getNormalizedXYZForXYZ: (xyz) ->
    new THREE.Vector3().copy(xyz).multiplyScalar(1 / @d65LuminanceFactor)

  @getLinearRGBForXYZ: (xyz) ->
    @getLinearRGBForNormalizedXYZ @getNormalizedXYZForXYZ xyz

  @getLinearRGBForNormalizedXYZ: (xyz) ->
    rgbVector = new THREE.Vector3().copy(xyz).applyMatrix3 @XYZtoLinearRGBTransform

    r: rgbVector.x
    g: rgbVector.y
    b: rgbVector.z

  @getXYZForLinearRGB: (linearRGB) ->
    @getXYZForNormalizedXYZ @getNormalizedXYZForLinearRGB(linearRGB)

  @getNormalizedXYZForLinearRGB: (linearRGB) ->
    new THREE.Vector3(linearRGB.r, linearRGB.g, linearRGB.b).applyMatrix3(@LinearRGBToXYZTransform)

  @getXYZForNormalizedXYZ: (xyz) ->
    new THREE.Vector3().copy(xyz).multiplyScalar(@d65LuminanceFactor)

  @getRGBForLinearRGB: (linearRGB) ->
    r: @gamma linearRGB.r
    g: @gamma linearRGB.g
    b: @gamma linearRGB.b

  @gamma: (value) ->
    if value <= 0.0031308 then 323 * value / 25 else (211 * Math.pow(value, 5 / 12) - 11) / 200

  @getLinearRGBForRGB: (rgb) ->
    r: @gammaInverse rgb.r
    g: @gammaInverse rgb.g
    b: @gammaInverse rgb.b

  @gammaInverse: (value) ->
    if value <= 0.04045 then 25 * value / 323 else Math.pow((200 * value + 11) / 211, 12 / 5)
