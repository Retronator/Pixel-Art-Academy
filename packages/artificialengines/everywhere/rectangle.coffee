AE = Artificial.Everywhere

class AE.Rectangle
  constructor: (x, y, width, height) ->
    if _.isObject x
      object = x

      if object instanceof AE.Rectangle
        x = object.x()
        y = object.y()
        width = object.width()
        height = object.height()

      else
        {x, y, width, height} = object

    @x = new ReactiveField x or 0
    @y = new ReactiveField y or 0
    @width = new ReactiveField width or 0
    @height = new ReactiveField height or 0

  # Construct a Rectangle object with a pair of any two of [left, right, width] and any two of [top, bottom, height].
  @fromDimensions: (dimensions) ->
    new AE.Rectangle
      x: dimensions.left ? dimensions.right - dimensions.width
      y: dimensions.top ? dimensions.bottom - dimensions.height
      width: dimensions.width ? dimensions.right - dimensions.left
      height: dimensions.height ? dimensions.bottom - dimensions.top

  ### Dimensions ###

  left: (value) ->
    @x value if value?

    @x()

  right: (value) ->
    @x value - @width if value?

    @x() + @width()

  top: (value) ->
    @y value if value?

    @y()

  bottom: (value) ->
    @y value - @height() if value?

    @y() + @height()

  center: ->
    x: @x() + @width() * 0.5
    y: @y() + @height() * 0.5

  # Converts to plain object (useful to access values directly, non-reactive).
  toObject: ->
    x: @x()
    y: @y()
    left: @left()
    right: @right()
    top: @top()
    bottom: @bottom()
    width: @width()
    height: @height()

  # Converts to plain dimensions object (useful in CSS). It doesn't have right/bottom since in CSS dimensions, that
  # would mean right/bottom offset from the container, whereas in the rectangle these are measurements from left/top.
  toDimensions: ->
    left: @left()
    top: @top()
    width: @width()
    height: @height()

  ### Operations ###

  # Returns the minimum rectangle that contains both rectangles
  @union: (a, b) ->
    UIRectangle.fromDimensions
      left: Math.min a.left(), b.left()
      right: Math.max a.right(), b.right()
      top: Math.min a.top(), b.top()
      bottom: Math.max a.bottom(), b.bottom()

  union: (other) ->
    @constructor.union @, other

  # Returns a rectangle with given offsets added to the sides of this rectangle.
  # 1 to 4 parameters can be used in the same manner as providing margins in CSS.
  extrude: (top, right, bottom, left) ->
    right ?= top
    bottom ?= top
    left ?= right

    AE.Rectangle.fromDimensions
      left: @left() - left
      right: @right() + right
      top: @top() - top
      bottom: @bottom() + bottom

  ### Utility ###

  @typeName: -> 'AE.Rectangle'
  typeName: -> @constructor.typeName()

  toJSONValue: ->
    x: @x()
    y: @y()
    width: @width()
    height: @height()

  clone: ->
    new AE.Rectangle @x(), @y(), @width(), @height()

  @equals: (a, b) ->
    return false unless a and b
    a.x?() is b.x?() and a.y?() is b.y?() and a.width?() is b.width?() and a.height?() is b.height?()

  equals: (other) ->
    @constructor.equals @, other

  toString: ->
    "#{@typeName()}{#{@x()}, #{@y()}, #{@width()}, #{@height()}}"

EJSON.addType AE.Rectangle.typeName(), (json) ->
  new AE.Rectangle json
