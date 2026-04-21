AM = Artificial.Mirage
AP = Artificial.Pyramid

class AP.Pages.BSpline extends AM.Component
  @register 'Artificial.Pyramid.Pages.BSpline'

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    @points = new ReactiveField []

    @bSpline = new ComputedField =>
      points = @points()
      return unless points.length in [3, 4]

      new AP.BSpline points

    @curvePolygonalChain = new ComputedField =>
      return unless bSpline = @bSpline()

      # Sample the B-spline into a polygonal chain that is dense enough to look smooth.
      bSpline.getPolygonalChain 200

  onRendered: ->
    super arguments...

    # Automatically redraw the graph when any reactive inputs change.
    @autorun =>
      @drawGraph()

  drawGraph: ->
    canvas = @$('.graph')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, canvas.width, canvas.height

    # Draw the background grid.
    context.beginPath()

    for lineIndex in [1..7]
      if lineIndex < 6
        context.moveTo 0, lineIndex * 100
        context.lineTo 800, lineIndex * 100

      context.moveTo lineIndex * 100, 0
      context.lineTo lineIndex * 100, 600

    context.strokeStyle = 'lightslategray'
    context.stroke()

    # Draw the control polygon with a faint line.
    points = @points()

    if points.length
      context.beginPath()
      context.moveTo points[0].x, points[0].y
      context.lineTo point.x, point.y for point in points[1...]
      context.strokeStyle = 'rgba(248, 248, 255, 0.25)'
      context.stroke()

    # Draw the sampled B-spline curve once enough control points exist.
    if curvePolygonalChain = @curvePolygonalChain()
      context.beginPath()
      context.moveTo curvePolygonalChain.vertices[0].x, curvePolygonalChain.vertices[0].y
      context.lineTo vertex.x, vertex.y for vertex in curvePolygonalChain.vertices[1...]
      context.strokeStyle = 'ghostwhite'
      context.stroke()

    # Draw the control points on top so they remain easy to inspect.
    context.fillStyle = 'white'
    @_drawPoint context, point.x, point.y, 3 for point in points

  _drawPoint: (context, x, y, radius) ->
    context.beginPath()
    context.arc x, y, radius, 0, Math.PI * 2
    context.fill()

  events: ->
    super(arguments...).concat
      'click .graph': @onClickGraph
      'click .reset-button': @onClickResetButton

  onClickGraph: (event) ->
    points = @points()
    return if points.length >= 4

    points.push new THREE.Vector2 event.offsetX, event.offsetY

    @points points

  onClickResetButton: (event) ->
    @points []
