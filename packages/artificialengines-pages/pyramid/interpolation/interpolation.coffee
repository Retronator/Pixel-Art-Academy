AB = Artificial.Babel
AM = Artificial.Mirage
AP = Artificial.Pyramid

class AP.Pages.Interpolation extends AM.Component
  @register 'Artificial.Pyramid.Pages.Interpolation'

  @InterpolationTypes:
    LagrangePolynomial: 'LagrangePolynomial'
    PiecewisePolynomial: 'PiecewisePolynomial'

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    @interpolationType = new ReactiveField @constructor.InterpolationTypes.LagrangePolynomial

    @points = new ReactiveField []

    @degree = new ReactiveField 1
    @extrapolate = new ReactiveField true

    @polynomial = new ComputedField =>
      points = @points()
      return unless points.length

      switch @interpolationType()
        when @constructor.InterpolationTypes.LagrangePolynomial
          AP.Interpolation.LagrangePolynomial.getFunctionForPoints points

        when @constructor.InterpolationTypes.PiecewisePolynomial
          AP.Interpolation.PiecewisePolynomial.getFunctionForPoints points, @degree(), @extrapolate()

  onRendered: ->
    super arguments...

    # Automatically update the graph.
    @autorun (computation) =>
      @drawGraph()

  lagrangePolynomialDegreeString: ->
    AB.Rules.English.createOrdinal @points().length - 1

  piecewisePolynomialDegreeString: ->
    AB.Rules.English.createOrdinal Math.min (@points().length - 1), @degree()

  drawGraph: ->
    canvas = @$('.graph')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, canvas.width, canvas.height

    # Draw grid.
    for i in [1..7]
      if i < 6
        # Draw a horizontal line.
        context.moveTo 0, i * 100
        context.lineTo 800, i * 100

      # Draw a vertical line.
      context.moveTo i * 100, 0
      context.lineTo i * 100, 600

    context.strokeStyle = 'lightslategrey'
    context.stroke()

    # Draw polynomial.
    return unless polynomial = @polynomial()

    context.beginPath()

    context.lineTo x, polynomial(x) for x in [0...canvas.width]

    context.strokeStyle = 'ghostwhite'
    context.stroke()

    # Draw anchor points.
    context.fillStyle = 'white'
    @_drawPoint context, point.x, point.y, 3 for point in @points()

  _drawPoint: (context, x, y, radius) ->
    context.beginPath()
    context.arc x, y, radius, 0, Math.PI * 2
    context.fill()

  events: ->
    super(arguments...).concat
      'click .reset-button': @onClickResetButton
      'click .graph': @onClickGraph

  onClickResetButton: (event) ->
    @points []

  onClickGraph: (event) ->
    points = @points()

    points.push
      x: event.offsetX
      y: event.offsetY

    @points points

  class @PropertyInputComponent extends AM.DataInputComponent
    onCreated: ->
      super arguments

      @polynomial = @ancestorComponentOfType AP.Pages.Interpolation

    load: ->
      @polynomial[@propertyName]()

    save: (value) ->
      @polynomial[@propertyName] value

  class @InterpolationType extends @PropertyInputComponent
    @register 'Artificial.Pyramid.Pages.Interpolation.InterpolationType'

    constructor: ->
      super arguments...

      @propertyName = 'interpolationType'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      names =
        LagrangePolynomial: 'Lagrange polynomial'
        PiecewisePolynomial: 'Piecewise polynomial'

      {value, name} for value, name of names

  class @Degree extends @PropertyInputComponent
    @register 'Artificial.Pyramid.Pages.Interpolation.Degree'

    constructor: ->
      super arguments...

      @propertyName = 'degree'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: 5

  class @Extrapolate extends @PropertyInputComponent
    @register 'Artificial.Pyramid.Pages.Interpolation.Extrapolate'

    constructor: ->
      super arguments...

      @propertyName = 'extrapolate'
      @type = AM.DataInputComponent.Types.Checkbox
