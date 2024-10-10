AS = Artificial.Spectrum
AR = Artificial.Reality

_xyz = new THREE.Vector3
_rgb = new THREE.Color

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

  @xyzNormalizationFactor = 2.2178461498317438e-7 # Calculated with getXYZNormalizationFactor method and cached for speed.

  @getXYZNormalizationFactor: ->
    # We want to normalize XYZ values such that Y is 1 for the D65 spectrum.
    d65Spectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()
    1 / AS.Color.CIE1931.getYForSpectrum d65Spectrum

  # XYZ -> RGB

  @getNormalizedXYZForXYZ: (xyz, target = new THREE.Vector3) ->
    target.copy(xyz).multiplyScalar(@xyzNormalizationFactor)

  @getNormalizedRGBForXYZ: (xyz, target = new THREE.Color) ->
    @getNormalizedXYZForXYZ xyz, _xyz
    @getRGBForXYZ _xyz, target

  @getRGBForXYZ: (xyz, target = new THREE.Color) ->
    rgbVector = new THREE.Vector3().copy(xyz).applyMatrix3 @XYZtoRGBTransform
    
    target.r = rgbVector.x
    target.g = rgbVector.y
    target.b = rgbVector.z
    
    target

  # RGB -> XYZ

  @getXYZForNormalizedRGB: (linearRGB, target = new THREE.Vector3) ->
    @getXYZForRGB linearRGB, _xyz
    @getXYZForNormalizedXYZ _xyz, target

  @getXYZForRGB: (linearRGB, target = new THREE.Vector3) ->
    target.set(linearRGB.r, linearRGB.g, linearRGB.b).applyMatrix3(@RGBToXYZTransform)

  @getXYZForNormalizedXYZ: (xyz, target = new THREE.Vector3) ->
   target.copy(xyz).multiplyScalar(1 / @xyzNormalizationFactor)

  # Gamma

  @getGammaRGBForNormalizedRGB: (linearRGB, target = new THREE.Color) ->
    target.r = @gamma linearRGB.r
    target.g = @gamma linearRGB.g
    target.b = @gamma linearRGB.b
    target

  @getGammaRGBForXYZ: (xyz, target = new THREE.Color) ->
    @getNormalizedRGBForXYZ xyz, _rgb
    @getGammaRGBForNormalizedRGB _rgb, target

  @gamma: (value) ->
    if value <= 0.0031308 then 323 * value / 25 else (211 * Math.pow(value, 5 / 12) - 11) / 200

  @getNormalizedRGBForGammaRGB: (rgb, target = new THREE.Color) ->
    target.r = @gammaInverse rgb.r
    target.g = @gammaInverse rgb.g
    target.b = @gammaInverse rgb.b
    target

  @gammaInverse: (value) ->
    if value <= 0.04045 then 25 * value / 323 else Math.pow((200 * value + 11) / 211, 12 / 5)
