AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.PixelCanvas extends FM.EditorView.Editor
  # initialCameraScale: default scale for camera if not specified on the file
  # scrollingEnabled: boolean whether you can scroll to pan and zoom
  # components: array of helper IDs that should be drawn to context
  # fixedCanvasSize: boolean whether to automatically match the canvas size to the size of the asset
  #
  # EDITOR FILE DATA
  # camera:
  #   scale: canvas magnification
  #   origin: the point on the asset that should appear in the center of the canvas
  #     x
  #     y
  # pixelGrid:
  #   enabled: boolean whether to draw the pixel grid
  # invertUIColors: boolean whether to draw UI elements with a light color (good for dark backgrounds)
  # landmarksEnabled: boolean whether to draw the landmarks
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.PixelCanvas'
  @register @id()
  
  @componentDataFields: -> [
    'initialCameraScale'
    'scrollingEnabled'
    'components'
    'fixedCanvasSize'
  ]

  @editorFileDataFieldsWithDefaults: ->
    landmarksEnabled: true

  constructor: (@options) ->
    super arguments...
    
    @camera = new ReactiveField null
    @mouse = new ReactiveField null
    @cursor = new ReactiveField null
    @landmarks = new ReactiveField null
    @pixelGrid = new ReactiveField null
    @operationPreview = new ReactiveField null
    @toolInfo = new ReactiveField null

    @$pixelCanvas = new ReactiveField null
    @canvas = new ReactiveField null
    @canvasPixelSize = new ReactiveField {width: 0, height: 0}, EJSON.equals
    @context = new ReactiveField null

  onCreated: ->
    super arguments...

    @display = @callAncestorWith 'display'
    
    if @options?.asset
      # We have the asset provided directly.
      @asset = new ComputedField =>
        @options.asset()

      @assetData = new ComputedField =>
        @asset()?.options.assetData()

      @assetId = new ComputedField =>
        @assetData()?._id

    else if @options?.assetData
      @assetData = @options?.assetData

    else
      # We need to get the asset from the loader.
      @loader = new ComputedField =>
        activeFileId = @editorView.activeFileId()
        @interface.getLoaderForFile activeFileId

      @assetData = new ComputedField =>
        @loader()?.asset()

      @assetId = new ComputedField =>
        return unless assetData = @assetData()
        assetData._id
  
    @paintNormalsData = @interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).child 'paintNormals'
  
    # Create the engine sprite.
    @assetDataClass = new ComputedField =>
      return unless assetData = @assetData()
      assetData.constructor
    ,
      (a, b) => a is b
    
    @pixelImage = new ComputedField =>
      @_pixelImage?.destroy?()
      
      return unless assetDataClass = @assetDataClass()
      
      if assetDataClass is LOI.Assets.Bitmap
        pixelImageClass = LOI.Assets.Engine.PixelImage.Bitmap
        
      else if assetDataClass is LOI.Assets.Sprite
        pixelImageClass = LOI.Assets.Engine.PixelImage.Sprite
        
      else
        throw new AE.ArgumentException "Unsupported asset data class.", assetDataClass
  
      @_pixelImage = new pixelImageClass
        asset: @assetData
        visualizeNormals: @paintNormalsData.value
  
      @_pixelImage

    # Initialize components.
    @camera new @constructor.Camera @, $parent: @$pixelCanvas
    @mouse new @constructor.Mouse @
    @cursor new @constructor.Cursor @
    @landmarks new @constructor.Landmarks @
    @pixelGrid new @constructor.PixelGrid @
    @operationPreview new @constructor.OperationPreview @
    @toolInfo new @constructor.ToolInfo @

    # Prepare helpers.
    @fileIdForHelpers = new ComputedField =>
      if @options?.fileIdForHelpers
        @options.fileIdForHelpers()

      else
        @editorView.activeFileId()

    @lightDirectionHelper = new ComputedField =>
      @interface.getHelperForFile LOI.Assets.SpriteEditor.Helpers.LightDirection, @fileIdForHelpers()

    @landmarksHelper = new ComputedField =>
      landmarksHelperClass = @options?.landmarksHelperClass or LOI.Assets.SpriteEditor.Helpers.Landmarks
      @interface.getHelperForFile landmarksHelperClass, @fileIdForHelpers()

    @shadingEnabled = new ComputedField =>
      @editorFileData()?.get('shadingEnabled') ? true

    @drawComponents = new ComputedField =>
      if @options?.drawComponents
        drawComponents = _.clone @options.drawComponents()

      else
        drawComponents = [@pixelImage(), @operationPreview(), @pixelGrid(), @cursor(), @landmarks(), @toolInfo()]
        
      if componentIds = @components()
        for componentId in componentIds
          helper = @interface.getHelperForFile componentId, @fileIdForHelpers()

          # If the helper provides components, we add each of them in turn.
          if helper.components
            for componentInfo in helper.components()
              # See if we have the component specified with extra requirements.
              if componentInfo.component
                # Handle the 'before' requirement.
                if componentInfo.before
                  targetIndex = _.findIndex drawComponents, (drawComponent) => drawComponent instanceof componentInfo.before
                  drawComponents.splice targetIndex, 0, componentInfo.component

              else
                # The component was directly sent. Add it to the end.
                drawComponents.push componentInfo

          else
            # Otherwise the helper will be directly drawn to context.
            drawComponents.push helper

      drawComponents

    # Reactively redraw the canvas.
    @autorun => @_redraw()
    
  _redraw: ->
    return unless context = @context()
  
    canvasPixelSize = @canvasPixelSize()
  
    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, canvasPixelSize.width, canvasPixelSize.height
  
    camera = @camera()
    camera.applyTransformToCanvas()
  
    lightDirection = @lightDirectionHelper()
    shadingEnabled = @shadingEnabled()
  
    for component in @drawComponents()
      continue unless component
    
      context.save()
      component.drawToContext context,
        lightDirection: if shadingEnabled then lightDirection() else null
        camera: camera
        editor: @
        smoothShading: false
    
      context.restore()

  onRendered: ->
    super arguments...

    # DOM has been rendered, initialize.
    $pixelCanvas = @$('.landsofillusions-assets-spriteeditor-pixelcanvas')
    @$pixelCanvas $pixelCanvas

    canvas = $pixelCanvas.find('.canvas')[0]
    @canvas canvas
    @context canvas.getContext '2d'

    # React to canvas element resizing.
    @_resizeObserver = new ResizeObserver (entries) =>
      for entry in entries when entry.borderBoxSize?.length
        @_resizeCanvas
          width: Math.floor entry.borderBoxSize[0].inlineSize
          height: Math.floor entry.borderBoxSize[0].blockSize
          
    # Reactively resize to react to fixed size.
    @autorun (computation) =>
      @_resizeCanvas
        width: $pixelCanvas.width()
        height: $pixelCanvas.height()
  
    @_resizeObserver.observe canvas

    # React to keys and global mouse events.
    $(document).on 'keydown.landsofillusions-assets-spriteeditor-pixelcanvas', (event) => @interface.activeTool()?.onKeyDown? event if @interface.active()
    $(document).on 'keyup.landsofillusions-assets-spriteeditor-pixelcanvas', (event) => @interface.activeTool()?.onKeyUp? event if @interface.active()
    $(document).on 'mouseup.landsofillusions-assets-spriteeditor-pixelcanvas', (event) => @interface.activeTool()?.onMouseUp? event if @interface.active()
    $(document).on 'mouseleave.landsofillusions-assets-spriteeditor-pixelcanvas', (event) => @interface.activeTool()?.onMouseLeaveWindow? event if @interface.active()
    
  _resizeCanvas: (newSize) ->
    # Override size if we're using fixed canvas size.
    if @fixedCanvasSize()
      effectiveScale = @camera().effectiveScale()
      bounds = @assetData()?.bounds
  
      newSize.width = (bounds?.width or 0) * effectiveScale
      newSize.height = (bounds?.height or 0) * effectiveScale
      
      if @pixelGrid().enabled()
        # Add 1px extra for outer grid.
        newSize.width++
        newSize.height++
    
    changedCanvasSize = false
    
    # Resize the back buffer to canvas element size, if it changed.
    canvas = @canvas()
    
    for key, value of newSize when canvas[key] isnt value
      canvas[key] = value
      changedCanvasSize = true
  
    @canvasPixelSize newSize
  
    # Redraw the image to prevent flickering since the reactive routine won't kick in until the next frame.
    @_redraw() if changedCanvasSize

  onDestroyed: ->
    super arguments...
  
    @_resizeObserver?.disconnect()

    $(document).off '.landsofillusions-assets-spriteeditor-pixelcanvas'

  # Events

  events: ->
    super(arguments...).concat
      'mousedown .canvas': @onMouseDownCanvas
      'mousemove .canvas': @onMouseMoveCanvas
      'mouseenter .canvas': @onMouseEnterCanvas
      'mouseleave .canvas': @onMouseLeaveCanvas
      'dragstart .canvas': @onDragStartCanvas

  onMouseDownCanvas: (event) ->
    @interface.activeTool()?.onMouseDown? event if @interface.active()

  onMouseMoveCanvas: (event) ->
    @interface.activeTool()?.onMouseMove? event if @interface.active()

  onMouseEnterCanvas: (event) ->
    @interface.activeTool()?.onMouseEnter? event if @interface.active()

  onMouseLeaveCanvas: (event) ->
    @interface.activeTool()?.onMouseLeave? event if @interface.active()

  onDragStartCanvas: (event) ->
    @interface.activeTool()?.onDragStart? event if @interface.active()
