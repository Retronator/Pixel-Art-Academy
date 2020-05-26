AP = Artificial.Pyramid

# Efficient implementation of complex numbers with operations that modify existing object (like three.js).
class AP.ComplexNumber
  constructor: (@real = 0, @imaginary = 0) ->

  set: (real, imaginary) ->
    console.warn "Real part of the complex number was not provided." unless real?
    console.warn "Imaginary part of the complex number was not provided." unless imaginary?

    @real = real
    @imaginary = imaginary

    # Return self to allow chaining.
    @

  copy: (other) ->
    @real = other.real
    @imaginary = other.imaginary
    @

  # Value properties

  absoluteValue: ->
    Math.sqrt @real ** 2 + @imaginary ** 2

  argument: ->
    Math.atan2 @imaginary, @real

  # Arithmetic operations

  add: (other) ->
    @real += other.real
    @imaginary += other.imaginary
    @

  addReal: (otherReal) ->
    @real += otherReal
    @

  subtract: (other) ->
    @real -= other.real
    @imaginary -= other.imaginary
    @

  subtractReal: (otherReal) ->
    @real -= otherReal
    @

  multiply: (other) ->
    newReal = @real * other.real - @imaginary * other.imaginary
    @imaginary = @real * other.imaginary + @imaginary * other.real
    @real = newReal
    @

  multiplyReal: (otherReal) ->
    @real = @real * otherReal
    @imaginary = @imaginary * otherReal
    @

  divide: (other) ->
    scalar = 1 / (other.real ** 2 + other.imaginary ** 2)
    newReal = scalar * (@real * other.real + @imaginary * other.imaginary)
    @imaginary = scalar * (@imaginary * other.real - @real * other.imaginary)
    @real = newReal
    @

  divideReal: (otherReal) ->
    @real /= otherReal
    @imaginary /= otherReal
    @

  sqrt: ->
    #                  _______      _______
    #  _    _______   /|z| + x     /|z| - x
    # √z = √x + iy = /-------- ± i/--------
    #               √     2      √     2
    #
    absoluteValue = @absoluteValue()

    newReal = Math.sqrt((absoluteValue + @real) / 2)
    @imaginary = (Math.sign(@imaginary) or 1) * Math.abs(Math.sqrt((absoluteValue - @real) / 2))
    @real = newReal
    @

  log: ->
    #
    # log(z) = ln|z| + i⋅Arg(z)
    #
    newReal = Math.log @absoluteValue()
    @imaginary = @argument()
    @real = newReal
    @

  # Trigonometry operations

  sin: ->
    newReal = Math.sin(@real) * Math.cosh(@imaginary)
    @imaginary = Math.cos(@real) * Math.sinh(@imaginary)
    @real = newReal
    @

  cos: ->
    newReal = Math.cos(@real) * Math.cosh(@imaginary)
    @imaginary = -Math.sin(@real) * Math.sinh(@imaginary)
    @real = newReal
    @

  asin: ->
    #                         ______
    # arcsin(z) = -i⋅ln(iz + √1 - z²)
    #
    temp2.copy(@).multiply(AP.ComplexNumber.I)
    temp.copy(@).multiply(@).multiplyReal(-1).addReal(1).sqrt().add(temp2).log().multiply(AP.ComplexNumber.MinusI)
    @copy temp
    @

  # Utility

  @typeName: -> 'AP.ComplexNumber'
  typeName: -> @constructor.typeName()

  toJSONValue: ->
    real: @real
    imaginary: @imaginary

  clone: ->
    new AP.ComplexNumber @real, @imaginary

  @equals: (a, b) ->
    return false unless a and b
    a.real is b.real and a.imaginary is b.imaginary

  equals: (other) ->
    @constructor.equals @, other

  toString: ->
    if @imaginary >= 0
      "#{@typeName()}{#{@real} + #{@imaginary}i}"

    else
      "#{@typeName()}{#{@real} - #{Math.abs @imaginary}i}"

AP.ComplexNumber.I = new AP.ComplexNumber 0, 1
AP.ComplexNumber.MinusI = new AP.ComplexNumber 0, -1

temp = new AP.ComplexNumber
temp2 = new AP.ComplexNumber
