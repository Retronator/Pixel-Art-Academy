# Extra functionality for the color class.

_xyz = new THREE.Vector3
_rgb = new THREE.Color
_lab = {}
_lch = {}

# Convert the color to a plain object.
THREE.Color::toObject = ->
  r: @r
  g: @g
  b: @b
  
# Convert the color to an array of byte values.
THREE.Color::toByteArray = ->
  Math.floor value * 255 for value in [@r, @g, @b]

# Normalizes the color to have unit green component.
THREE.Color::normalize = ->
  if @g
    @r /= @g
    @b /= @g
    @g = 1

  else
    @r = 1
    @g = 1
    @b = 1

THREE.Color::getLCh = (target) ->
  Color = Artificial.Spectrum.Color
  Color.SRGB.getNormalizedRGBForGammaRGB @, _rgb
  Color.SRGB.getXYZForRGB _rgb, _xyz
  Color.CIELAB.getLabForNormalizedXYZ _xyz, _lab
  Color.CIELAB.getLChForLab _lab, target
  
THREE.Color::setLCh = (l, c, h) ->
  _lch.l = l
  _lch.c = c
  _lch.h = h
  Color = Artificial.Spectrum.Color
  Color.CIELAB.getLabForLCh _lch, _lab
  Color.CIELAB.getNormalizedXYZForLab _lab, _xyz
  Color.SRGB.getRGBForXYZ _xyz, _rgb
  Color.SRGB.getGammaRGBForNormalizedRGB _rgb, @
  
# Create a new color from a plain object.
THREE.Color.fromObject = (object) ->
  return new THREE.Color().copy object
