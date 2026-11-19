AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Blueprint.Camera
  constructor: (@blueprint) ->
    @state = new LOI.StateObject address: @blueprint.studyPlan.stateAddress.child 'camera'
    
    # At camera scale 1, a canvas pixel matches a display pixel (and not window pixel).
    # Scale is used to go from canvas pixels to display pixels. We use lazy updates to minimize state reactivity.
    @scale = @state.field 'scale',
      equalityFunction: EJSON.equals
      lazyUpdates: true

    @scale 1 unless @scale()

    # Effective scale includes the amount we're scaling our display pixels.
    # It is used to go from canvas pixels to window pixels.
    @effectiveScale = new ComputedField =>
      displayScale = @blueprint.display.scale()
      @scale() * displayScale

    # Origin tells which coordinate is at the center of the canvas. We use lazy updates to minimize state reactivity.
    @origin = @state.field 'origin',
      equalityFunction: EJSON.equals
      lazyUpdates: true

    @origin x: 0, y: 0 unless @origin()

    @_preciseOrigin = @origin()

    @viewportBounds = new AE.Rectangle()
    @boundOrigin = new ComputedField => @_bindPosition @origin()
    
    # Calculate viewport in canvas coordinates.
    @blueprint.autorun =>
      effectiveScale = @effectiveScale()
      origin = @boundOrigin()

      # Calculate which part of the canvas is visible. Canvas bounds is in window pixels.
      width = @blueprint.bounds.width() / effectiveScale
      height = @blueprint.bounds.height() / effectiveScale

      @viewportBounds.width width
      @viewportBounds.height height
      @viewportBounds.x origin.x - width / 2
      @viewportBounds.y origin.y - height / 2

    # Enable panning with scrolling.

    # Wire up mouse wheel event once the sprite editor is rendered.
    @blueprint.autorun (computation) =>
      $blueprint = @blueprint.$blueprint()
      return unless $blueprint
      computation.stop()

      $blueprint.on 'wheel', (event) =>
        event.preventDefault()

        effectiveScale = @effectiveScale()

        windowDelta =
          x: event.originalEvent.deltaX
          y: event.originalEvent.deltaY

        canvasDelta =
          x: windowDelta.x / effectiveScale
          y: windowDelta.y / effectiveScale

        @offsetOrigin canvasDelta

    # Use a detached element to animate camera coordinates with Velocity.
    @_$animate = $('<div>')
    
  _bindPosition: (position) ->
    xOffset = @viewportBounds.width() * 0.25
    yOffset = @viewportBounds.height() * 0.25
    x: _.clamp position.x, @blueprint.mapBoundingRectangle.left() - xOffset, @blueprint.mapBoundingRectangle.right() + xOffset
    y: _.clamp position.y, @blueprint.mapBoundingRectangle.top() - yOffset, @blueprint.mapBoundingRectangle.bottom() + yOffset
  
  setOrigin: (origin) ->
    # Direct camera movement takes over from any pending animated focus.
    @stopAnimating()
    @_setOrigin origin

  animateToOrigin: (origin, duration = 300) ->
    @stopAnimating()

    startOrigin = @_bindPosition @_preciseOrigin
    endOrigin = @_bindPosition origin

    # Return a promise so we can await for the animation to finish.
    new Promise (resolve) =>
      # Store the resolve function so we can cancel the animation if needed.
      @_resolveOriginAnimation = resolve

      @_$animate.velocity
        tween: [1, 0]
      ,
        duration: duration
        easing: 'ease'
        progress: (elements, complete, remaining, current, tweenValue) =>
          return unless tweenValue?

          @_setOrigin
            x: startOrigin.x + (endOrigin.x - startOrigin.x) * tweenValue
            y: startOrigin.y + (endOrigin.y - startOrigin.y) * tweenValue

        complete: =>
          @_setOrigin endOrigin
          @_resolveOriginAnimation = null
          resolve true

  stopAnimating: ->
    @_$animate.velocity 'stop', true
    
    # Resolve with false when interrupted so callers never wait indefinitely or highlight a cancelled target.
    @_resolveOriginAnimation? false
    @_resolveOriginAnimation = null

  _setOrigin: (origin) ->
    @_preciseOrigin = @_bindPosition origin

    @origin
      x: Math.floor @_preciseOrigin.x
      y: Math.floor @_preciseOrigin.y

  offsetOrigin: (offset) ->
    @setOrigin
      x: @_preciseOrigin.x + offset.x
      y: @_preciseOrigin.y + offset.y

  applyTransformToCanvas: ->
    context = @blueprint.context()
    effectiveScale = @effectiveScale()
    origin = @boundOrigin()

    # Start from the identity.
    context.setTransform 1, 0, 0, 1, 0, 0

    # Move to center of screen.
    width = @blueprint.bounds.width()
    height = @blueprint.bounds.height()
    context.translate width / 2, height / 2

    # Scale the canvas around the origin.
    context.scale effectiveScale, effectiveScale

    # Move to origin.
    context.translate -origin.x, -origin.y

  transformCanvasToWindow: (canvasCoordinate) ->
    effectiveScale = @effectiveScale()
    origin = @boundOrigin()

    x = canvasCoordinate.x
    y = canvasCoordinate.y
    width = @blueprint.bounds.width()
    height = @blueprint.bounds.height()

    x: (x - origin.x) * effectiveScale + width / 2
    y: (y - origin.y) * effectiveScale + height / 2

  transformCanvasToDisplay: (canvasCoordinate) ->
    windowCoordinate = @transformCanvasToWindow canvasCoordinate
    displayScale = @blueprint.display.scale()

    x: windowCoordinate.x / displayScale
    y: windowCoordinate.y / displayScale

  transformWindowToCanvas: (windowCoordinate) ->
    effectiveScale = @effectiveScale()
    origin = @boundOrigin()

    x = windowCoordinate.x
    y = windowCoordinate.y
    width = @blueprint.bounds.width()
    height = @blueprint.bounds.height()

    x: (x - width / 2) / effectiveScale + origin.x
    y: (y - height / 2) / effectiveScale + origin.y

  transformDisplayToCanvas: (displayCoordinate) ->
    displayScale = @blueprint.display.scale()

    windowCoordinate =
      x: displayCoordinate.x * displayScale
      y: displayCoordinate.y * displayScale

    @transformWindowToCanvas windowCoordinate

  roundCanvasToWindowPixel: (canvasCoordinate, lineWidth = 1) ->
    windowCoordinate = @transformCanvasToWindow canvasCoordinate
    pixelPerfectWindowCoordinate =
      x: Math.floor(windowCoordinate.x) + lineWidth / 2
      y: Math.floor(windowCoordinate.y) + lineWidth / 2

    @transformWindowToCanvas pixelPerfectWindowCoordinate
