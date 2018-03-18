AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.PixelCanvas extends AM.Component
  @register 'LandsOfIllusions.Assets.Components.PixelCanvas'

  constructor: (@options) ->
    super

    _.defaults @options,
      cameraInput: true
      grid: true
      mouse: true
      cursor: true

    # Prepare all reactive fields.
    @camera = new ReactiveField null
    @grid = new ReactiveField null
    @mouse = new ReactiveField null
    @cursor = new ReactiveField null
    @sprite = new ReactiveField null

    @$pixelCanvas = new ReactiveField null
    @canvas = new ReactiveField null
    @canvasBounds = new AE.Rectangle()
    @context = new ReactiveField null

  onCreated: ->
    super

    @display = @callAncestorWith 'display'

    # Initialize components.
    @camera new @constructor.Camera @,
      initialScale: @options.initialCameraScale
      enableInput: @options.cameraInput

    if @options.grid
      @grid new @constructor.Grid @

    if @options.mouse
      @mouse new @constructor.Mouse @

    if @options.cursor
      @cursor new @constructor.Cursor @

    # Resize the canvas when browser window changes.
    @autorun =>
      canvas = @canvas()
      return unless canvas
      
      # Depend on window size.
      AM.Window.clientBounds()

      # Resize the back buffer to canvas element size, if it actually changed. If the pixel
      # canvas is not actually sized relative to window, we shouldn't force a redraw of the sprite.
      newSize =
        width: $(canvas).width()
        height: $(canvas).height()

      for key, value of newSize
        canvas[key] = value unless canvas[key] is value

      @canvasBounds.width canvas.width
      @canvasBounds.height canvas.height

    # Redraw canvas routine.
    @autorun =>
      camera = @camera()
      context = @context()
      return unless context

      context.setTransform 1, 0, 0, 1, 0, 0
      context.clearRect 0, 0, @canvasBounds.width(), @canvasBounds.height()

      camera.applyTransformToCanvas()

      parentDrawComponents = @options.drawComponents?() or []

      for component in [parentDrawComponents..., @grid(), @cursor()]
        continue unless component

        context.save()
        component.drawToContext context, lightDirection: @options.lightDirection
        context.restore()

  onRendered: ->
    super

    # DOM has been rendered, initialize.
    $pixelCanvas = @$('.landsofillusions-assets-components-pixelcanvas')
    @$pixelCanvas $pixelCanvas

    canvas = $pixelCanvas.find('.canvas')[0]
    @canvas canvas
    @context canvas.getContext '2d'

    if @options.activeTool
      $(window).on 'keydown.landsofillusions-assets-components-pixelcanvas', (event) => @options.activeTool()?.onKeyDown? event
      $(window).on 'keyup.landsofillusions-assets-components-pixelcanvas', (event) => @options.activeTool()?.onKeyUp? event

  onDestroyed: ->
    super

    $(window).off '.landsofillusions-assets-components-pixelcanvas'

  # Events

  events: ->
    super.concat
    events = super

    if @options.activeTool
      events = events.concat
        'mousedown .canvas': @onMouseDownCanvas
        'mouseup .canvas': @onMouseUpCanvas
        'mousemove .canvas': @onMouseMoveCanvas

    events

  onMouseDownCanvas: (event) ->
    @options.activeTool()?.onMouseDown? event

  onMouseUpCanvas: (event) ->
    @options.activeTool()?.onMouseUp? event

  onMouseMoveCanvas: (event) ->
    @options.activeTool()?.onMouseMove? event
