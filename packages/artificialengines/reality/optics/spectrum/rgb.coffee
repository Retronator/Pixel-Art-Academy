AR = Artificial.Reality

xyzCoordinates = ['x', 'y', 'z']

# An RGB spectrum holds the sRGB linear RGB representation of the spectrum.
class AR.Optics.Spectrum.RGB extends AR.Optics.Spectrum.Array
  @ArrayLength: 3

  constructor: (options) ->
    super options?.values

    @options = options or {}

  matchesType: (spectrum) ->
    spectrum instanceof AR.Optics.Spectrum.RGB

  getValue: (wavelength) ->
    # Return radiance in W / sr⋅m³
    intensity = 0

    xyz = @toXYZ()

    for coordinate, index in xyzCoordinates
      response = Artificial.Spectrum.Color.CIE1931.ColorMatchingFunctions[coordinate].getValue wavelength
      intensity += response * xyz[coordinate]

    intensity

  toObject: ->
    r: @array[0]
    g: @array[1]
    b: @array[2]

  toXYZ: ->
    Artificial.Spectrum.Color.SRGB.getXYZForLinearRGB @toObject()

  copy: (spectrum) ->
    # If the spectrum is a matching RGB spectrum, we can simply copy the array.
    return super arguments... if @matchesType spectrum

    # Convert the spectrum to RGB.
    rgb = @_getRGBForSpectrum spectrum
    @array[0] = rgb.r
    @array[1] = rgb.g
    @array[2] = rgb.b

    return @

  _getRGBForSpectrum: (spectrum) ->
    xyz = Artificial.Spectrum.Color.CIE1931.getXYZForSpectrum spectrum
    Artificial.Spectrum.Color.SRGB.getLinearRGBForXYZ xyz

  copyFactor: (spectrum) ->
    # If the spectrum is a matching RGB spectrum, we can simply copy the array.
    return @copy spectrum if @matchesType spectrum

    # Convert the factor spectrum to XYZ.
    normalizedXYZ = Artificial.Spectrum.Color.CIE1931.getXYZFactorsForSpectrum spectrum
    rgb = Artificial.Spectrum.Color.SRGB.getLinearRGBForNormalizedXYZ normalizedXYZ
    @array[0] = rgb.r
    @array[1] = rgb.g
    @array[2] = rgb.b

    return @

  add: (spectrum) ->
    return super arguments... if @matchesType spectrum

    # Convert the spectrum to RGB.
    rgb = @_getRGBForSpectrum spectrum
    @array[0] += rgb.r
    @array[1] += rgb.g
    @array[2] += rgb.b

    return @

  subtract: (spectrum) ->
    return super arguments... if @matchesType spectrum

    # Convert the spectrum to RGB.
    rgb = @_getRGBForSpectrum spectrum
    @array[0] -= rgb.r
    @array[1] -= rgb.g
    @array[2] -= rgb.b

    return @

  multiply: (spectrum) ->
    return super arguments... if @matchesType spectrum

    # Convert the spectrum to RGB.
    rgb = @_getRGBForSpectrum spectrum
    @array[0] *= rgb.r
    @array[1] *= rgb.g
    @array[2] *= rgb.b

    return @
