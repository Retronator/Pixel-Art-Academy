AE = Artificial.Everywhere
AR = Artificial.Reality

xyzCoordinates = ['x', 'y', 'z']

# An XYZ spectrum holds the CIE1931 XYZ representation of the spectrum.
class AR.Optics.Spectrum.XYZ extends AR.Optics.Spectrum.Array
  @ArrayLength: 3

  constructor: (options) ->
    super options?.values

    @options = options or {}

  matchesType: (spectrum) ->
    spectrum instanceof AR.Optics.Spectrum.XYZ

  getValue: (wavelength) ->
    # Return radiance in W / sr⋅m³
    throw new AE.NotImplementedException "XYZ Spectrum sampling is not supported yet."

  toObject: ->
    x: @array[0]
    y: @array[1]
    z: @array[2]

  toXYZ: ->
    @toObject()

  copy: (spectrum) ->
    # If the spectrum is a matching XYZ spectrum, we can simply copy the array.
    return super arguments... if @matchesType spectrum

    # Convert the spectrum to XYZ.
    xyz = Artificial.Spectrum.Color.XYZ.getXYZForSpectrum spectrum
    @array[0] = xyz.x
    @array[1] = xyz.y
    @array[2] = xyz.z

    return @

  copyFactor: (spectrum, referenceIlluminant) ->
    # If the spectrum is a matching XYZ spectrum, we can simply copy the array.
    return @copy spectrum if @matchesType spectrum

    # Convert the factor spectrum to XYZ.
    xyz = Artificial.Spectrum.Color.XYZ.getXYZFactorsForSpectrum spectrum, referenceIlluminant
    @array[0] = xyz.x
    @array[1] = xyz.y
    @array[2] = xyz.z

    return @

  add: (spectrum) ->
    return super arguments... if @matchesType spectrum

    # Convert the spectrum to XYZ.
    xyz = Artificial.Spectrum.Color.XYZ.getXYZForSpectrum spectrum
    @array[0] += xyz.x
    @array[1] += xyz.y
    @array[2] += xyz.z

    return @

  subtract: (spectrum) ->
    return super arguments... if @matchesType spectrum

    # Convert the spectrum to XYZ.
    xyz = Artificial.Spectrum.Color.XYZ.getXYZForSpectrum spectrum
    @array[0] -= xyz.x
    @array[1] -= xyz.y
    @array[2] -= xyz.z

    return @

  multiply: (spectrum) ->
    return super arguments... if @matchesType spectrum

    # Convert the spectrum to XYZ.
    xyz = Artificial.Spectrum.Color.XYZ.getXYZForSpectrum spectrum
    @array[0] *= xyz.x
    @array[1] *= xyz.y
    @array[2] *= xyz.z

    return @
