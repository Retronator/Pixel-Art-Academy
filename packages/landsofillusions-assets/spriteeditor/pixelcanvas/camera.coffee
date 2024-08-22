AC = Artificial.Control
AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.PixelCanvas.Camera
  constructor: (@pixelCanvas, options) ->
    @cameraData = new ComputedField =>
      @pixelCanvas.interface.getActiveFileData()?.child 'camera'

    @scaleData = new ComputedField =>
      @cameraData()?.child 'scale'

    # At camera scale 1, a canvas pixel matches a display pixel (and not window pixel).
    # Scale is used to go from canvas pixels to display pixels.
    @scale = new ComputedField =>
      @scaleData()?.value() or @pixelCanvas.initialCameraScale() or 1

    # Effective scale includes the amount we're scaling our display pixels.
    # It is used to go from canvas pixels to window pixels.
    @effectiveScale = new ComputedField =>
      displayScale = @pixelCanvas.display.scale()
      @scale() * displayScale

    @smoothScrolling = new ComputedField =>
      @pixelCanvas.smoothScrolling()
      
    @scrollToZoom = new ComputedField =>
      @pixelCanvas.scrollToZoom()
      
    @originData = new ComputedField =>
      @cameraData()?.child 'origin'

    @origin = new ComputedField =>
      @originData()?.value() or x: 0, y: 0
    ,
      EJSON.equals
    
    @zoomLevelsHelper = @pixelCanvas.interface.getHelper LOI.Assets.SpriteEditor.Helpers.ZoomLevels
    
    # Dummy DOM element to run velocity on.
    @$animate = $('<div>')
    @_animating = false
    
    # Scale that we're currently at or animating towards.
    @targetScale = new ReactiveField @scale()
    
    # Automatically update to current scale when not animating.
    @pixelCanvas.autorun =>
      scale = @scale()
      return if @_animating
      
      @targetScale scale

    # Calculate various bounds. Canvas bounds are relative to the asset origin.
    @assetCanvasBounds = new AE.Rectangle()
    @drawingAreaCanvasBounds = new AE.Rectangle()
    @renderableAreaCanvasBounds = new AE.Rectangle()
    @viewportCanvasBounds = new AE.Rectangle()
    
    # Window bounds are relative to the center of the pixel canvas.
    @drawingAreaWindowBounds = new AE.Rectangle()
    @canvasWindowBounds = new AE.Rectangle()

    @pixelCanvas.autorun =>
      # Asset bounds are directly copied from the asset.
      return unless assetData = @pixelCanvas.assetData()
      
      @assetCanvasBounds.copy assetData.bounds
     
      # Calculate drawing area bounds in canvas coordinates.
      displayMode = @pixelCanvas.displayMode()
      borderWidth = @pixelCanvas.borderWidth() or 0
      
      if assetData.bounds.fixed or displayMode is LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Full
        # When the asset bounds are fixed, or if we're drawing the full canvas, the drawing area matches it directly.
        @drawingAreaCanvasBounds.copy assetData.bounds
        
        # Add an optional border around the asset.
        @drawingAreaCanvasBounds.extrude borderWidth, borderWidth if borderWidth
      
      else if displayMode is LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Framed
        # When the asset bounds are freeform and we need to frame the drawing, we make the drawing area 50% bigger than the existing asset bounds.
        verticalFreeformBorder = (assetData.bounds?.width or 128) * 0.25
        horizontalFreeformBorder = (assetData.bounds?.height or 128) * 0.25
        
        @drawingAreaCanvasBounds.copy(assetData.bounds).extrude verticalFreeformBorder, horizontalFreeformBorder
        
      else
        # Without the frame, the drawing area extends into infinity.
        @drawingAreaCanvasBounds.left Number.NEGATIVE_INFINITY
        @drawingAreaCanvasBounds.top Number.NEGATIVE_INFINITY
        @drawingAreaCanvasBounds.right Number.POSITIVE_INFINITY
        @drawingAreaCanvasBounds.bottom Number.POSITIVE_INFINITY
        
      if displayMode is LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Full
        # When the full canvas is rendered, pixel canvas is assumed to fully cover it, optionally with the border.
        @renderableAreaCanvasBounds.copy assetData.bounds
        @renderableAreaCanvasBounds.extrude borderWidth, borderWidth if borderWidth
      
      else
        pixelCanvasWindowSize = @pixelCanvas.windowSize()
        effectiveScale = @effectiveScale()
        width = pixelCanvasWindowSize.width / effectiveScale
        height = pixelCanvasWindowSize.height / effectiveScale
        origin = @origin()
    
        @renderableAreaCanvasBounds.width width
        @renderableAreaCanvasBounds.height height
        @renderableAreaCanvasBounds.x origin.x - width / 2
        @renderableAreaCanvasBounds.y origin.y - height / 2

      # Viewport bounds are the intersection of the pixel canvas bounds and the drawing area bounds.
      @viewportCanvasBounds.copy(@renderableAreaCanvasBounds).intersect @drawingAreaCanvasBounds
    
      if displayMode is LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Full
        effectiveScale = @effectiveScale()
        @drawingAreaWindowBounds.x -borderWidth
        @drawingAreaWindowBounds.y -borderWidth
        @drawingAreaWindowBounds.width (assetData.bounds.width + 2 * borderWidth) * effectiveScale
        @drawingAreaWindowBounds.height (assetData.bounds.height + 2 * borderWidth) * effectiveScale
  
        @canvasWindowBounds.copy @drawingAreaWindowBounds
        
      else
        # Calculate the bounds of the drawing area in window coordinates relative to the pixel canvas center.
        drawingAreaTopLeft = @transformCanvasToWindowCenter x: @drawingAreaCanvasBounds.left(), y: @drawingAreaCanvasBounds.top()
        drawingAreaBottomRight = @transformCanvasToWindowCenter x: @drawingAreaCanvasBounds.right(), y: @drawingAreaCanvasBounds.bottom()
        
        @drawingAreaWindowBounds.copy
          left: drawingAreaTopLeft.x
          top: drawingAreaTopLeft.y
          right: drawingAreaBottomRight.x
          bottom: drawingAreaBottomRight.y
    
        # Calculate the bounds of the canvas in window coordinates relative to the drawing area top left corner.
        canvasTopLeft = @transformCanvasToWindowCenter x: @viewportCanvasBounds.left(), y: @viewportCanvasBounds.top()
        canvasBottomRight = @transformCanvasToWindowCenter x: @viewportCanvasBounds.right(), y: @viewportCanvasBounds.bottom()

        # Fit the transformed coordinates and add extra padding to the size for the outer grid line.
        @canvasWindowBounds.copy
          left: canvasTopLeft.x
          top: canvasTopLeft.y
          width: Math.floor(canvasBottomRight.x) - Math.floor(canvasTopLeft.x) + 1
          height: Math.floor(canvasBottomRight.y) - Math.floor(canvasTopLeft.y) + 1
          
    # Enable smooth pan and zoom with scrolling.
    @pixelCanvas.autorun (computation) =>
      # Wire up pointer wheel event once the sprite editor is rendered.
      $parent = options.$parent()
      return unless $parent
      
      smoothScrolling = @smoothScrolling()
      
      if smoothScrolling and not @_scrollingFunction
        # Enable the wheel event.
        @_scrollingFunction = (event) => @_onSmoothScrollingWheel event
        $parent.on 'wheel', @_scrollingFunction
        
      else if @_scrollingFunction and not smoothScrolling
        # Disable the wheel event.
        $parent.off 'wheel', @_scrollingFunction
        
    # Enable discrete zoom changes with scrolling.
    @pixelCanvas.autorun (computation) =>
      # Create the discrete wheel event listener once the sprite editor is rendered.
      $parent = options.$parent()
      return unless $parent
      
      scrollToZoom = @scrollToZoom()
      
      if scrollToZoom and not @_discreteWheelEventListener
        # Enable the wheel event.
        @_discreteWheelEventListener = new AC.DiscreteWheelEventListener
          callback: (sign) => @_onScrollToZoom sign
          timeout: 0.1
          element: $parent[0]
        
      else if @_discreteWheelEventListener and not scrollToZoom
        # Disable the wheel event.
        @_discreteWheelEventListener.destroy()
        @_discreteWheelEventListener = null
  
  _onSmoothScrollingWheel: (event) ->
    event.preventDefault()

    effectiveScale = @effectiveScale()

    if event.ctrlKey
      # User is zooming in/out.
      delta = event.originalEvent.deltaY

      scale = @scale()
      scaleChange = Math.pow(0.99, delta)

      @setScale scale * scaleChange

      # Also move the origin, depending on how much off-center we were zooming.
      canvasOrigin = $parent.offset()

      pointerWindowCoordinate =
        x: event.originalEvent.pageX - canvasOrigin.left
        y: event.originalEvent.pageY - canvasOrigin.top

      pointerCanvasCoordinate = @transformWindowToCanvas pointerWindowCoordinate

      oldOrigin = @origin()

      offCenter =
        x: pointerCanvasCoordinate.x - oldOrigin.x
        y: pointerCanvasCoordinate.y - oldOrigin.y

      @originData().value
        x: oldOrigin.x + offCenter.x * (scaleChange - 1)
        y: oldOrigin.y + offCenter.y * (scaleChange - 1)

    else
      # User is translating.

      windowDelta =
        x: event.originalEvent.deltaX
        y: event.originalEvent.deltaY

      canvasDelta =
        x: windowDelta.x / effectiveScale
        y: windowDelta.y / effectiveScale

      oldOrigin = @origin()

      @originData().value
        x: oldOrigin.x + canvasDelta.x
        y: oldOrigin.y + canvasDelta.y
        
  _onScrollToZoom: (sign) ->
    # Don't scroll if ctrl is pressed (that changes brush size).
    keyboardState = AC.Keyboard.getState()
    return if keyboardState.isKeyDown AC.Keys.ctrl
    
    zoomLevels = @zoomLevelsHelper()
    percentage = @targetScale() * 100
    
    newZoomLevel = null
    
    if sign > 0
      # Zoom out.
      for zoomLevel in zoomLevels by -1
        if Math.round(zoomLevel) < Math.round(percentage)
          newZoomLevel = zoomLevel
          break
          
    else
      # Zoom in.
      for zoomLevel in zoomLevels
        if Math.round(zoomLevel) > Math.round(percentage)
          newZoomLevel = zoomLevel
          break
          
    return unless newZoomLevel
    newScale = newZoomLevel / 100
    
    scrollToZoom = @scrollToZoom()
    
    if scrollToZoom.animate
      @scaleTo newScale, scrollToZoom.animate.duration
      
    else
      @setScale newScale
  
  setScale: (scale) ->
    @scaleData().value scale

  setOrigin: (origin) ->
    @originData().value origin
    
  scaleTo: (scale, duration) ->
    scaleData = @scaleData()
    currentScale = @targetScale()
    
    @targetScale scale
    @_animating = true
    
    @$animate.velocity('stop', 'scale').velocity
      tween: [scale, currentScale]
    ,
      duration: duration * 1000
      easing: 'ease'
      queue: 'scale'
      progress: (elements, complete, remaining, current, tweenValue) =>
        # HACK: For some reason, progress is called twice, once with tweenValue set to null.
        return unless tweenValue

        scaleData.value tweenValue
      complete: =>
        @_animating = false
    
    @$animate.dequeue('scale')
  
  translateTo: (origin, duration) ->
    originData = @originData()
    currentOrigin = _.clone originData.value()
    
    @$animate.velocity('stop', 'origin').velocity
      tween: [1, 0]
    ,
      duration: duration * 1000
      easing: 'ease'
      queue: 'origin'
      progress: (elements, complete, remaining, current, tweenValue) =>
        # HACK: For some reason, progress is called twice, once with tweenValue set to null.
        return unless tweenValue

        originData.value
          x: THREE.MathUtils.lerp currentOrigin.x, origin.x, tweenValue
          y: THREE.MathUtils.lerp currentOrigin.y, origin.y, tweenValue
    
    @$animate.dequeue('origin')

  applyTransformToCanvas: ->
    context = @pixelCanvas.context()
    effectiveScale = @effectiveScale()
    canvasScale = effectiveScale * devicePixelRatio

    # Start from the identity.
    context.setTransform 1, 0, 0, 1, 0, 0

    # Scale the canvas around the origin.
    context.scale canvasScale, canvasScale

    # Move to viewport corner.
    translateX = @viewportCanvasBounds.x()
    translateY = @viewportCanvasBounds.y()
    context.translate -translateX, -translateY

  transformCanvasToWindowCenter: (canvasCoordinate, target = {}) ->
    effectiveScale = @effectiveScale()
    origin = @origin()
  
    target.x = (canvasCoordinate.x - origin.x) * effectiveScale
    target.y = (canvasCoordinate.y - origin.y) * effectiveScale
  
    target
    
  transformCanvasToWindow: (canvasCoordinate, target = {}) ->
    @transformCanvasToWindowCenter canvasCoordinate, target
  
    pixelCanvasWindowSize = @pixelCanvas.windowSize()
    width = pixelCanvasWindowSize.width
    height = pixelCanvasWindowSize.height
    
    target.x += width / 2
    target.y += height / 2
  
    target

  transformCanvasToDisplay: (canvasCoordinate, target = {}) ->
    @transformCanvasToWindow canvasCoordinate, target
    displayScale = @pixelCanvas.display.scale()

    target.x /= displayScale
    target.y /= displayScale

    target

  transformWindowToCanvas: (windowCoordinate, target = {}) ->
    pixelCanvasWindowSize = @pixelCanvas.windowSize()

    target.x = windowCoordinate.x - pixelCanvasWindowSize.width / 2
    target.y = windowCoordinate.y - pixelCanvasWindowSize.height / 2
    
    @transformWindowCenterToCanvas target, target
  
  transformWindowCenterToCanvas: (windowCoordinate, target = {}) ->
    effectiveScale = @effectiveScale()
    origin = @origin()
    
    target.x = windowCoordinate.x / effectiveScale + origin.x
    target.y = windowCoordinate.y / effectiveScale + origin.y
    
    target

  transformDisplayToCanvas: (displayCoordinate, target = {}) ->
    displayScale = @pixelCanvas.display.scale()

    target.x = displayCoordinate.x * displayScale
    target.y = displayCoordinate.y * displayScale

    @transformWindowToCanvas target, target

  roundCanvasToWindowPixel: (canvasCoordinate, target = {}) ->
    @transformCanvasToWindowCenter canvasCoordinate, target
    
    # Transform to corner of the canvas.
    canvasX = @canvasWindowBounds.x()
    canvasY = @canvasWindowBounds.y()
    target.x -= canvasX
    target.y -= canvasY
    
    # Move to the center of the pixel.
    target.x = Math.floor(target.x) + 0.5
    target.y = Math.floor(target.y) + 0.5
    
    # Transform back to window center.
    target.x += canvasX
    target.y += canvasY

    @transformWindowCenterToCanvas target, target

  debugOutput: ->
    console.log "PIXEL CANVAS CAMERA"
    console.log "scale:", @scale()
    console.log "origin:", @origin()
    
    console.log "asset canvas bounds", @assetCanvasBounds.toDimensions()
    console.log "drawing area canvas bounds", @drawingAreaCanvasBounds.toDimensions()
    console.log "renderable area canvas bounds", @renderableAreaCanvasBounds.toDimensions()
    console.log "viewport canvas bounds", @viewportCanvasBounds.toDimensions()
    
    console.log "drawing area window bounds", @drawingAreaWindowBounds.toDimensions()
    console.log "canvas window bounds", @canvasWindowBounds.toDimensions()
