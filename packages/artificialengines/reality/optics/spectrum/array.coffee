AR = Artificial.Reality

# An array spectrum uses a backing array to (arbitrarily) describe the values in the spectrum.
class AR.Optics.Spectrum.Array extends AR.Optics.Spectrum
  @ArrayLength: null # Override to define the length of the backing array of the spectrum.

  constructor: (startingValues) ->
    super arguments...

    arrayLength = @constructor.ArrayLength or startingValues?.length

    console.warn "Array spectrum dimensions could not be determined." unless arrayLength?

    # Create and fill the backing array.
    @array = new Float32Array arrayLength

    if startingValues
      @array[index] = value for value, index in startingValues

    else
      @array.fill 0

  set: (values) ->
    @array[index] = value for value, index in values
    return @

  setConstant: (value) ->
    @array[index] = value for index in [0...@array.length]
    return @

  clear: ->
    @array.fill 0
    return @

  negate: ->
    @array[index] = -value for value, index in @array
    return @

  power: (exponent) ->
    @array[index] = Math.pow value, exponent for value, index in @array
    return @

  exp: ->
    @array[index] = Math.exp value for value, index in @array
    return @

  multiplyScalar: (scalar) ->
    @array[index] *= scalar for index in [0...@array.length]
    return @

  copy: (spectrum) ->
    if @matchesType spectrum
      for value, index in spectrum.array
        @array[index] = value

    return @

  add: (spectrum) ->
    if @matchesType spectrum
      for value, index in spectrum.array
        @array[index] += value

    return @

  subtract: (spectrum) ->
    if @matchesType spectrum
      for value, index in spectrum.array
        @array[index] -= value

    return @

  multiply: (spectrum) ->
    if @matchesType spectrum
      for value, index in spectrum.array
        @array[index] *= value

    return @
