AB = Artificial.Babel
AM = Artificial.Mirage
AP = Artificial.Pyramid

class AP.Pages.PolygonalChain.Decimate extends AM.Component
  @register 'Artificial.Pyramid.Pages.PolygonalChain.Decimate'

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    @vertices = new ReactiveField []

    @epsilon = new ReactiveField 0
    
    @polygonalChain = new ComputedField =>
      vertices = @vertices()
      new AP.PolygonalChain vertices
      
    @decimatedPolygonalChain = new ComputedField =>
      return unless polygonalChain = @polygonalChain()
      polygonalChain.getDecimatedPolygonalChain @epsilon()

  onRendered: ->
    super arguments...

    # Automatically update the graph.
    @autorun (computation) =>
      @drawGraph()

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

    context.strokeStyle = 'lightslategray'
    context.stroke()

    # Draw the base polygonal chain.
    return unless polygonalChain = @polygonalChain()

    context.beginPath()

    context.lineTo vertex.x, vertex.y for vertex in polygonalChain.vertices

    context.strokeStyle = 'lightslategray'
    context.stroke()
    
    # Draw the decimated polygonal chain.
    return unless decimatedPolygonalChain = @decimatedPolygonalChain()
    
    context.beginPath()
    
    context.lineTo vertex.x, vertex.y for vertex in decimatedPolygonalChain.vertices
    
    context.strokeStyle = 'ghostwhite'
    context.stroke()

    # Draw anchor vertices.
    context.fillStyle = 'white'
    @_drawvertex context, vertex.x, vertex.y, 3 for vertex in @vertices()

  _drawvertex: (context, x, y, radius) ->
    context.beginPath()
    context.arc x, y, radius, 0, Math.PI * 2
    context.fill()

  events: ->
    super(arguments...).concat
      'click .reset-button': @onClickResetButton
      'click .graph': @onClickGraph

  onClickResetButton: (event) ->
    @vertices []

  onClickGraph: (event) ->
    vertices = @vertices()

    vertices.push new THREE.Vector2 event.offsetX, event.offsetY

    @vertices vertices

  class @PropertyInputComponent extends AM.DataInputComponent
    onCreated: ->
      super arguments

      @decimate = @ancestorComponentOfType AP.Pages.PolygonalChain.Decimate

    load: ->
      @decimate[@propertyName]()

    save: (value) ->
      @decimate[@propertyName] value

  class @Epsilon extends @PropertyInputComponent
    @register 'Artificial.Pyramid.Pages.Decimate.Epsilon'

    constructor: ->
      super arguments...

      @propertyName = 'epsilon'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: 100
