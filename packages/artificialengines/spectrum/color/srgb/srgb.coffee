AS = Artificial.Spectrum

class AS.Color.SRGB
  @XYZtoLinearRGBTransform = new THREE.Matrix3().set(
    3.2406, -1.5372, -0.4986,
    -0.9689, 1.8758, 0.0415,
    0.0557, -0.204, 1.057
  )

  @getLinearRGBForXYZ: (xyz) ->
    new THREE.Vector3.copy(xyz).transform @XYZtoLinearRGBTransform

  @getRGBForLinearRGB: (linearRGB) ->
    r: @gamma linearRGB.r
    g: @gamma linearRGB.g
    b: @gamma linearRGB.b

  @gamma: (value) ->
    if value <= 0.0031308 then 12.92 * value else 1.055 * Math.pow(value, 0.41666666) - 0.055
