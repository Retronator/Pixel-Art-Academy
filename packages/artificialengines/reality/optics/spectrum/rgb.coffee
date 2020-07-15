AE = Artificial.Everywhere
AR = Artificial.Reality

xyzCoordinates = ['x', 'y', 'z']

# An RGB spectrum holds the (non-normalized) linear RGB representation of the spectrum.
class AR.Optics.Spectrum.RGB extends AR.Optics.Spectrum.Array
  @ArrayLength: 3

  constructor: (options) ->
    super options?.values

    @options = options or {}

  matchesType: (spectrum) ->
    spectrum instanceof AR.Optics.Spectrum.RGB

  getValue: (wavelength) ->
    # Return radiance in W / sr⋅m³
    throw new AE.NotImplementedException "RGB Spectrum sampling is not supported yet."

  toObject: ->
    r: @array[0]
    g: @array[1]
    b: @array[2]

  toVector3: ->
    new THREE.Vector3 @array[0], @array[1], @array[2]

  toXYZ: ->
    Artificial.Spectrum.Color.SRGB.getXYZForRGB @toObject()

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
    Artificial.Spectrum.Color.SRGB.getRGBForXYZ xyz

  copyFactor: (spectrum) ->
    # If the spectrum is a matching RGB spectrum, we can simply copy the array.
    return @copy spectrum if @matchesType spectrum

    # Convert the factor spectrum to XYZ.
    normalizedXYZ = Artificial.Spectrum.Color.CIE1931.getXYZFactorsForSpectrum spectrum
    normalizedRGB = Artificial.Spectrum.Color.SRGB.getRGBForXYZ normalizedXYZ
    @array[0] = normalizedRGB.r
    @array[1] = normalizedRGB.g
    @array[2] = normalizedRGB.b

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
