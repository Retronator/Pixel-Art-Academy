AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Components.PixelCanvas extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Components.PixelCanvas'
  @register @id()

  @subscribeToDocumentsForEditorView: (editorView, filesData) ->
    ids = (fileData.id for fileData in filesData)
    LOI.Assets.Asset.forIdsFull.subscribe editorView, LOI.Assets.Sprite.className, ids

  @getDocumentForEditorView: (editorView, fileData) ->
    return unless fileData?.id

    LOI.Assets.Sprite.documents.findOne fileData.id

  constructor: ->
    super arguments...
    
    @options =
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
    @canvasPixelSize = new ReactiveField width: 0, height: 0
    @context = new ReactiveField null

  onCreated: ->
    super arguments...

    @display = @callAncestorWith 'display'
    @interface = @ancestorComponentOfType FM.Interface

    # Initialize components.
    @camera new @constructor.Camera @,
      initialScale: @options.initialCameraScale
      initialOrigin: @options.initialCameraOrigin
      enableInput: @options.cameraInput

    if @options.grid
      @grid new @constructor.Grid @, @options.gridInvertColor, @options.gridEnabled

    if @options.mouse
      @mouse new @constructor.Mouse @

    if @options.cursor
      @cursor new @constructor.Cursor @

    @spriteId = new ComputedField =>
      @interface.activeFileData()?.id

    @spriteData = new ComputedField =>
      return unless spriteId = @spriteId()

      LOI.Assets.Asset.forId.subscribe LOI.Assets.Sprite.className, spriteId
      LOI.Assets.Sprite.documents.findOne spriteId

    @paletteId = new ComputedField =>
      # Minimize reactivity to only palette changes.
      LOI.Assets.Sprite.documents.findOne(@spriteId(),
        fields:
          palette: 1
      )?.palette?._id

    @sprite new LOI.Assets.Engine.Sprite
      spriteData: @spriteData
      #visualizeNormals: @paintNormals

    @pixelCanvasSize = new ReactiveField width: 0, height: 0

    # Resize the canvas when browser window and zoom changes.
    @autorun (computation) =>
      canvas = @canvas()
      return unless canvas
      
      if @options.canvasSize
        # Resize based on provided canvas size.
        size = @options.canvasSize()
        scale = @camera().effectiveScale()
        
        newSize =
          width: (size?.width or 0) * scale
          height: (size?.height or 0) * scale

        gridEnabled = if _.isFunction(@options.grid) then @options.grid() else @options.grid

        if gridEnabled
          # Add 1px extra for outer grid.
          newSize.width++
          newSize.height++
        
      else
        # Resize to component.
        newSize = @pixelCanvasSize()

      # Resize the back buffer to canvas element size, if it actually changed. If the pixel
      # canvas is not actually sized relative to window, we shouldn't force a redraw of the sprite.
      for key, value of newSize
        canvas[key] = value unless canvas[key] is value

      @canvasPixelSize newSize

    # Redraw canvas routine.
    @autorun =>
      return unless context = @context()

      canvasPixelSize = @canvasPixelSize()

      context.setTransform 1, 0, 0, 1, 0, 0
      context.clearRect 0, 0, canvasPixelSize.width, canvasPixelSize.height

      camera = @camera()
      camera.applyTransformToCanvas()

      components = [@sprite()]

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
    super arguments...

    # DOM has been rendered, initialize.
    $pixelCanvas = @$('.landsofillusions-assets-components-pixelcanvas')
    @$pixelCanvas $pixelCanvas

    canvas = $pixelCanvas.find('.canvas')[0]
    @canvas canvas
    @context canvas.getContext '2d'

    @autorun (computation) =>
      # Depend on editor view size.
      AM.Window.clientBounds()

      # Depend on application area changes.
      @interface.currentApplicationAreaData().value()

      # After update, measure the size.
      Tracker.afterFlush =>
        @pixelCanvasSize
          width: $pixelCanvas.width()
          height: $pixelCanvas.height()

    if @options.activeTool
      $(document).on 'keydown.landsofillusions-assets-components-pixelcanvas', (event) => @options.activeTool()?.onKeyDown? event
      $(document).on 'keyup.landsofillusions-assets-components-pixelcanvas', (event) => @options.activeTool()?.onKeyUp? event
      $(document).on 'mouseup.landsofillusions-assets-components-pixelcanvas', (event) => @options.activeTool()?.onMouseUp? event
      $(document).on 'mouseleave.landsofillusions-assets-components-pixelcanvas', (event) => @options.activeTool()?.onMouseLeaveWindow? event

  onDestroyed: ->
    super arguments...

    $(document).off '.landsofillusions-assets-components-pixelcanvas'

  # Events

  events: ->
    events = super arguments...

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
