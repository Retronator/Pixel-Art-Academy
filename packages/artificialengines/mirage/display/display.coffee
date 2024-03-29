AE = Artificial.Everywhere
AM = Artificial.Mirage

# Represents the display area and provides automatic pixel art scaling calculation.
class AM.Display extends AM.Component
  @register 'Artificial.Mirage.Display'

  constructor: (options) ->
    super arguments...
    
    # We allow sending in our own reactive functions, but if they are not present, we create our own field.
    createField = (name) ->
      if _.isFunction options[name] then options[name] else new ReactiveField options[name]

    # The size at which to start calculating at x1 scale.
    @safeAreaWidth = createField 'safeAreaWidth'
    @safeAreaHeight = createField 'safeAreaHeight'

    # The scales at which to start and end calculating.
    @minScale = createField 'minScale'
    @maxScale = createField 'maxScale'

    # The aspect ratio to maintain with the final image.
    @minAspectRatio = createField 'minAspectRatio'
    @maxAspectRatio = createField 'maxAspectRatio'

    # The maximum displayed size at x1 scale. The viewport can be anywhere between safe area size and max display size.
    @maxDisplayWidth = createField 'maxDisplayWidth'
    @maxDisplayHeight = createField 'maxDisplayHeight'

    # The maximum scaled displayed size. It's as if the client size couldn't go over this size.
    @maxClientWidth = createField 'maxClientWidth'
    @maxClientHeight = createField 'maxClientHeight'

    @scale = new ReactiveField 1
    @viewport = new ReactiveField
      viewportBounds: new AE.Rectangle()
      maxBounds: new AE.Rectangle()
      safeArea: new AE.Rectangle()

    @debug = new ReactiveField options.debug ? false

  onCreated: ->
    super arguments...

    @window = AM.Window

    # React to window size changes.
    @autorun =>
      debug = @debug()

      if debug
        console.log ""
        console.log "DISPLAY CALCULATION"
        console.log ""

      scale = @minScale() or 1
      maxScale = @maxScale()
      clientBounds = @window.clientBounds()
      clientWidth = clientBounds.width()
      clientHeight = clientBounds.height()
      maxClientWidth = @maxClientWidth()
      maxClientHeight = @maxClientHeight()
      safeAreaWidth = @safeAreaWidth()
      safeAreaHeight = @safeAreaHeight()
      minAspectRatio = @minAspectRatio()
      maxAspectRatio = @maxAspectRatio()
      maxDisplayWidth = @maxDisplayWidth()
      maxDisplayHeight = @maxDisplayHeight()

      # We might not have the full client bounds to work with due to aspect ratio.
      clientAspectRatio = clientWidth / clientHeight

      console.log "Client size: #{clientWidth}x#{clientHeight} at #{clientAspectRatio} ratio" if debug
      console.log "Aspect ratio range: #{minAspectRatio or 0}–#{maxAspectRatio or "infinity"}" if debug
      console.log "Max client size: #{maxClientWidth or clientWidth}x#{maxClientHeight or clientHeight}" if debug

      usableClientSize =
        width: if maxClientWidth then Math.min clientWidth, maxClientWidth else clientWidth
        height: if maxClientHeight then Math.min clientHeight, maxClientHeight else clientHeight

      usableClientAspectRatio = usableClientSize.width / usableClientSize.height

      console.log "Usable Client Size: #{usableClientSize.width}x#{usableClientSize.height} at #{usableClientAspectRatio} ratio" if debug

      usableClientAspectRatio = Math.max usableClientAspectRatio, minAspectRatio if minAspectRatio
      usableClientAspectRatio = Math.min usableClientAspectRatio, maxAspectRatio if maxAspectRatio

      # If image is too tall, add crop bars on top/bottom.
      usableClientSize.height = usableClientSize.width / usableClientAspectRatio if clientAspectRatio < usableClientAspectRatio

      # If image is too wide, add crop bars on left/right.
      usableClientSize.width = usableClientSize.height * usableClientAspectRatio if clientAspectRatio > usableClientAspectRatio

      console.log "Cropped usable Client Size: #{usableClientSize.width}x#{usableClientSize.height} at #{usableClientAspectRatio} ratio" if debug

      # Calculate new scale.
      loop
        console.log "Testing scale at x#{scale + 1}" if debug
        # Calculate safe area size at next scale level.
        scaledSafeAreaWidth = safeAreaWidth * (scale + 1)
        scaledSafeAreaHeight = safeAreaHeight * (scale + 1)
        safeAreaAspectRatio = safeAreaWidth / safeAreaHeight

        # Calculate minimum viewport ratio.
        minViewportSize =
          width: scaledSafeAreaWidth
          height: scaledSafeAreaHeight

        # Make sure the aspect ratio is within range.
        minViewportAspectRatio = minViewportSize.width / minViewportSize.height
        minViewportAspectRatio = Math.max minViewportAspectRatio, minAspectRatio if minAspectRatio
        minViewportAspectRatio = Math.min minViewportAspectRatio, maxAspectRatio if maxAspectRatio

        # If image is too tall, expand left/right.
        minViewportSize.width = minViewportSize.height * minViewportAspectRatio if safeAreaAspectRatio < minViewportAspectRatio

        # If image is too wide, expand up/down.
        minViewportSize.height = usableClientSize.width / minViewportAspectRatio if safeAreaAspectRatio > minViewportAspectRatio

        console.log "Min viewport size: #{minViewportSize.width}x#{minViewportSize.height} at #{minViewportAspectRatio}" if debug

        # Test if next scale level would make the minimum viewport go out of usable client bounds.
        break if minViewportSize.width > usableClientSize.width or minViewportSize.height > usableClientSize.height

        # Stop at max scale, if set.
        break if scale is maxScale

        # It is safe to increase the scale.
        scale++

      @scale scale

      # Calculate safe area size at decided scale level.
      scaledSafeAreaWidth = safeAreaWidth * scale
      scaledSafeAreaHeight = safeAreaHeight * scale
      safeAreaAspectRatio = safeAreaWidth / safeAreaHeight

      console.log "FINAL SCALE AT x#{scale} with safe area at #{scaledSafeAreaWidth}x#{scaledSafeAreaHeight}" if debug

      # Calculate minimum viewport ratio.
      minViewportSize =
        width: scaledSafeAreaWidth
        height: scaledSafeAreaHeight

      # Make sure the aspect ratio is within range.
      minViewportAspectRatio = minViewportSize.width / minViewportSize.height
      minViewportAspectRatio = Math.max minViewportAspectRatio, minAspectRatio if minAspectRatio
      minViewportAspectRatio = Math.min minViewportAspectRatio, maxAspectRatio if maxAspectRatio

      # If image is too tall, expand left/right.
      minViewportSize.width = minViewportSize.height * minViewportAspectRatio if safeAreaAspectRatio < minViewportAspectRatio

      # If image is too wide, expand up/down.
      minViewportSize.height = usableClientSize.width / minViewportAspectRatio if safeAreaAspectRatio > minViewportAspectRatio

      console.log "Min viewport size: #{minViewportSize.width}x#{minViewportSize.height} at #{minViewportAspectRatio}" if debug

      # Make sure usable client size is not smaller than the minimum viewport.
      usableClientSize =
        width: Math.max usableClientSize.width, minViewportSize.width
        height: Math.max usableClientSize.height, minViewportSize.height

      usableClientAspectRatio = usableClientSize.width / usableClientSize.height

      # Calculate maximum viewport size.
      maxViewportSize =
        width: if maxDisplayWidth then Math.min Math.round(maxDisplayWidth * scale), usableClientSize.width else usableClientSize.width
        height: if maxDisplayHeight then Math.min Math.round(maxDisplayHeight * scale), usableClientSize.height else usableClientSize.height

      # Calculate viewport ratio, clamped to our limits.
      maxViewportAspectRatio = maxViewportSize.width / maxViewportSize.height

      console.log "Max viewport size: #{maxViewportSize.width}x#{maxViewportSize.height} at #{maxViewportAspectRatio}" if debug

      viewportRatio = maxViewportAspectRatio
      viewportRatio = Math.max viewportRatio, minAspectRatio if minAspectRatio
      viewportRatio = Math.min viewportRatio, maxAspectRatio if maxAspectRatio

      # Calculate viewport size. By default it is the maximum viewport size, but make sure it doesn't exceed the viewport ratio.
      viewportSize =
        width: maxViewportSize.width
        height: maxViewportSize.height

      scaledMaxDisplaySize =
        width: if maxDisplayWidth then maxDisplayWidth * scale else maxViewportSize.width
        height: if maxDisplayHeight then maxDisplayHeight * scale else maxViewportSize.height

      # If image is too tall, add crop bars on top/bottom.
      viewportSize.height = viewportSize.width / viewportRatio if maxViewportAspectRatio < viewportRatio

      # If image is too wide, add crop bars on left/right.
      viewportSize.width = viewportSize.height * viewportRatio if maxViewportAspectRatio > viewportRatio

      console.log "Viewport size: #{viewportSize.width}x#{viewportSize.height} at #{viewportRatio} ratio" if debug
      console.log "Maximum scaled display size: #{scaledMaxDisplaySize.width}x#{scaledMaxDisplaySize.height}" if debug

      # Make sure the bounds are centered so that at least the safe area stays within the actual client window.
      safeClientWidth = Math.max clientWidth, scaledSafeAreaWidth
      safeClientHeight = Math.max clientHeight, scaledSafeAreaHeight

      # Viewport bounds are the final visible area that will be maintained with the crop bars.
      viewportBounds = new AE.Rectangle
        x: Math.round (safeClientWidth - viewportSize.width) * 0.5
        y: Math.round (safeClientHeight - viewportSize.height) * 0.5
        width: Math.round viewportSize.width
        height: Math.round viewportSize.height

      # Maximum bounds are the bounds if the image was actually at maximum display size using this scale.
      maxBounds = new AE.Rectangle
        x: Math.round (safeClientWidth - scaledMaxDisplaySize.width) * 0.5
        y: Math.round (safeClientHeight - scaledMaxDisplaySize.height) * 0.5
        width: Math.round scaledMaxDisplaySize.width
        height: Math.round scaledMaxDisplaySize.height

      # Safe area is relative to the viewport (it will always be contained within).
      safeArea = new AE.Rectangle
        x: Math.round (viewportSize.width - scaledSafeAreaWidth) * 0.5
        y: Math.round (viewportSize.height - scaledSafeAreaHeight) * 0.5
        width: Math.round scaledSafeAreaWidth
        height: Math.round scaledSafeAreaHeight

      if @isRendered()
        # Update crop bars.
        $('.artificial-mirage-display .horizontal-crop-bar').css height: viewportBounds.top()
        $('.artificial-mirage-display .vertical-crop-bar').css width: viewportBounds.left()

        # Update debug rectangles.
        $('.artificial-mirage-display .viewport-bounds').css viewportBounds.toDimensions()
        $('.artificial-mirage-display .viewport-bounds .safe-area').css safeArea.toDimensions()

      @viewport
        viewportBounds: viewportBounds
        maxBounds: maxBounds
        safeArea: safeArea

    # Set scale attribute on html so we can scale cursors.
    @autorun (computation) =>
      if @_currentScale
        $('html').removeClass("scale-#{@_currentScale}")
        $('html').removeClass("scale-#{scale}-or-up") for scale in [2..@_currentScale]

      @_currentScale = @scale()
      $('html').addClass("scale-#{@_currentScale}")
      $('html').addClass("scale-#{scale}-or-up") for scale in [2..@_currentScale]

  debugClass: ->
    'debug' if @debug()
