AR = Artificial.Reality

# A uniformly sampled spectrum quadratically interpolates the values between a provided array of uniformly spaced samples.
class AR.Optics.Spectrum.UniformlySampled extends AR.Optics.Spectrum.Array
  @ExtrapolationTypes:
    Zero: 'Zero'
    Constant: 'Constant'

  constructor: (options) ->
    super options.values

    @options = options
    @options.extrapolationType ?= @constructor.ExtrapolationTypes.Zero

  matchesType: (spectrum) ->
    spectrum instanceof AR.Optics.Spectrum.UniformlySampled and
      spectrum.options.startingWavelength is @options.startingWavelength and
      spectrum.options.wavelengthSpacing is @options.wavelengthSpacing

  getValue: (wavelength) ->
    # Return radiance in W / sr⋅m³
    fractionalIndex = (wavelength - @options.startingWavelength) / @options.wavelengthSpacing

    middleValueIndex = _.clamp Math.round(fractionalIndex), 1, @array.length - 2

    values = [
      @array[middleValueIndex - 1]
      @array[middleValueIndex]
      @array[middleValueIndex + 1]
    ]

    firstValueWavelength = @options.startingWavelength + (middleValueIndex - 1) * @options.wavelengthSpacing

    x = (wavelength - firstValueWavelength) / @options.wavelengthSpacing

    # Handle values outside the samples.
    unless 0 <= x <= 2
      return 0 if @options.extrapolationType is @constructor.ExtrapolationTypes.Zero
      return if x < 0 then values[0] else values[2]

    y1 = values[0]
    y2 = values[1]
    y3 = values[2]

    a = (y3 - 2 * y2 + y1) / 2
    b = (y3 - 4 * y2 + 3 * y1) / -2
    c = y1

    a * x * x + b * x + c

  copy: (spectrum) ->
    # If the spectrum is a matching uniformly-spaced spectrum, we can simply copy the array.
    return super arguments... if @matchesType spectrum

    # Sample the other spectrum at our wavelengths.
    for i in [0...@array.length]
      wavelength = @options.startingWavelength + i * @options.wavelengthSpacing
      @array[i] = spectrum.getValue wavelength

    return @

  add: (spectrum) ->
    return super arguments... if @matchesType spectrum
    for i in [0...@array.length]
      wavelength = @options.startingWavelength + i * @options.wavelengthSpacing
      @array[i] += spectrum.getValue wavelength

    return @

  subtract: (spectrum) ->
    return super arguments... if @matchesType spectrum

    for i in [0...@array.length]
      wavelength = @options.startingWavelength + i * @options.wavelengthSpacing
      @array[i] -= spectrum.getValue wavelength

    return @

  multiply: (spectrum) ->
    return super arguments... if @matchesType spectrum

    for i in [0...@array.length]
      wavelength = @options.startingWavelength + i * @options.wavelengthSpacing
      @array[i] *= spectrum.getValue wavelength

    return @
