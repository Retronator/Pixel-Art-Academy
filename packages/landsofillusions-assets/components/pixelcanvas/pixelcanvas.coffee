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
      initialOrigin: @options.initialCameraOrigin
      enableInput: @options.cameraInput
      scaleDelay: @options.cameraScaleDelay

    if @options.grid
      @grid new @constructor.Grid @

    if @options.mouse
      @mouse new @constructor.Mouse @

    if @options.cursor
      @cursor new @constructor.Cursor @

    # Resize the canvas when browser window and zoom changes.
    @autorun =>
      canvas = @canvas()
      return unless canvas
      
      # Depend on window size.
      AM.Window.clientBounds()

      # Depend on camera scale if enabled.
      @camera().scale() if @options.resizeOnScale

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

      components = []

      if drawComponents = @options.drawComponents?()
        components = components.concat drawComponents

      for componentName in ['grid', 'cursor']
        if @options[componentName] is true or _.isFunction(@options[componentName]) and @options[componentName]()
          components.push @[componentName]()

      for component in components
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
      $(document).on 'keydown.landsofillusions-assets-components-pixelcanvas', (event) => @options.activeTool()?.onKeyDown? event
      $(document).on 'keyup.landsofillusions-assets-components-pixelcanvas', (event) => @options.activeTool()?.onKeyUp? event
      $(document).on 'mouseup.landsofillusions-assets-components-pixelcanvas', (event) => @options.activeTool()?.onMouseUp? event
      $(document).on 'mouseleave.landsofillusions-assets-components-pixelcanvas', (event) => @options.activeTool()?.onMouseLeaveWindow? event

  onDestroyed: ->
    super

    $(document).off '.landsofillusions-assets-components-pixelcanvas'

  forceResize: ->
    @forceResizeDependency.changed()

  # Events

  events: ->
    super.concat
    events = super

    if @options.activeTool
      events = events.concat
        'mousedown .canvas': @onMouseDownCanvas
        'mousemove .canvas': @onMouseMoveCanvas
        'mouseenter .canvas': @onMouseEnterCanvas
        'mouseleave .canvas': @onMouseLeaveCanvas
        'dragstart .canvas': @onDragStartCanvas

    events

  onMouseDownCanvas: (event) ->
    @options.activeTool()?.onMouseDown? event

  onMouseMoveCanvas: (event) ->
    @options.activeTool()?.onMouseMove? event

  onMouseEnterCanvas: (event) ->
    @options.activeTool()?.onMouseEnter? event

  onMouseLeaveCanvas: (event) ->
    @options.activeTool()?.onMouseLeave? event

  onDragStartCanvas: (event) ->
    @options.activeTool()?.onDragStart? event
