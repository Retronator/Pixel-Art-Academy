AE = Artificial.Everywhere

# A reactive rectangle data structure.
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
        {x, y, width, height} = @constructor._normalizeDimensions object

    @x = new ReactiveField x or 0
    @y = new ReactiveField y or 0
    @width = new ReactiveField width or 0
    @height = new ReactiveField height or 0

  # Calculates x, y, width, height with a pair of any two of [left, right, width] and any two of [top, bottom, height].
  @_normalizeDimensions: (dimensions) ->
    left = dimensions.x ? dimensions.left
    top = dimensions.y ? dimensions.top
    
    x: left ? dimensions.right - dimensions.width
    y: top ? dimensions.bottom - dimensions.height
    width: dimensions.width ? dimensions.right - dimensions.left
    height: dimensions.height ? dimensions.bottom - dimensions.top

  # Dimensions

  left: (value) ->
    @x value if value?

    @x()

  right: (value) ->
    @x value - @width() if value?

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
  
  set: (x, y, width, height) ->
    @x x
    @y y
    @width width
    @height height
  
    # Return self to allow chaining.
    @
    
  copy: (object) ->
    if object instanceof AE.Rectangle
      x = object.x()
      y = object.y()
      width = object.width()
      height = object.height()
      
    else if object.x? and object.y? and object.width? and object.height?
      {x, y, width, height} = object
      
    else
      {x, y, width, height} = @constructor._normalizeDimensions object

    @set x, y, width, height
  
    # Return self to allow chaining.
    @

  ### Operations ###

  # Returns the minimum rectangle that contains both rectangles.
  @union: (a, b) ->
    a.clone().union b

  union: (other) ->
    other = other.toObject()
    
    Tracker.nonreactive =>
      @copy
        left: Math.min @left(), other.left
        top: Math.min @top(), other.top
        right: Math.max @right(), other.right
        bottom: Math.max @bottom(), other.bottom
        
    # Return self to allow chaining.
    @

  # Returns the maximum rectangle that is contained within both rectangles.
  @intersect: (a, b) ->
    a.clone().intersect b
  
  intersect: (other) ->
    other = other.toObject()
    
    Tracker.nonreactive =>
      @copy
        left: Math.max @left(), other.left
        top: Math.max @top(), other.top
        right: Math.min @right(), other.right
        bottom: Math.min @bottom(), other.bottom
    
    # Return self to allow chaining.
    @
    
  # Returns a rectangle with given offsets added to the sides of this rectangle.
  # 1 to 4 parameters can be used in the same manner as providing margins in CSS.
  @extrude: (rectangle, top, right, bottom, left) ->
    rectangle.clone().extrude top, right, bottom, left
    
  extrude: (top, right, bottom, left) ->
    right ?= top
    bottom ?= top
    left ?= right
  
    Tracker.nonreactive =>
      @copy
        left: @left() - left
        right: @right() + right
        top: @top() - top
        bottom: @bottom() + bottom
  
    # Return self to allow chaining.
    @

  # Utility

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
