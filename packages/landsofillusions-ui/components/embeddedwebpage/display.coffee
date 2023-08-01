AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Components.EmbeddedWebpage.Display
  constructor: (@embeddedWebpage, @rootDisplay, options) ->
    # We allow sending in our own reactive functions, but if they are not present, we create our own field.
    createField = (name) ->
      if _.isFunction options[name] then options[name] else new ReactiveField options[name]

    @safeAreaWidth = createField 'safeAreaWidth'
    @safeAreaHeight = createField 'safeAreaHeight'

    @viewport = new ReactiveField
      viewportBounds: new AE.Rectangle()
      maxBounds: new AE.Rectangle()
      safeArea: new AE.Rectangle()

  initialize: ->
    # Update viewport when page root changes.
    @_resizeObserver = new ResizeObserver => @_updateViewport()
    @_resizeObserver.observe @embeddedWebpage.$root[0]

  destroy: ->
    @_resizeObserver.disconnect()

  scale: ->
    @rootDisplay.scale()

  _updateViewport: ->
    scale = @scale()
    safeAreaWidth = @safeAreaWidth()
    safeAreaHeight = @safeAreaHeight()

    clientWidth = @embeddedWebpage.$root.outerWidth()
    clientHeight = @embeddedWebpage.$root.outerHeight()

    # Calculate safe area size at decided scale level.
    scaledSafeAreaWidth = safeAreaWidth * scale
    scaledSafeAreaHeight = safeAreaHeight * scale

    # Calculate viewport size. Make sure it is not smaller than the safe area size.
    viewportSize =
      width: Math.max clientWidth, scaledSafeAreaWidth
      height: Math.max clientHeight, scaledSafeAreaHeight

    # Viewport bounds are the visible area of the embedded webpage root.
    viewportBounds = new AE.Rectangle
      x: 0
      y: 0
      width: Math.round viewportSize.width
      height: Math.round viewportSize.height

    # Maximum bounds are the same as viewport bounds since we currently don't support crop bars in embedded pages.
    maxBounds = viewportBounds.clone()

    # Safe area is relative to the viewport (it will always be contained within).
    safeArea = new AE.Rectangle
      x: Math.round (viewportSize.width - scaledSafeAreaWidth) * 0.5
      y: Math.round (viewportSize.height - scaledSafeAreaHeight) * 0.5
      width: Math.round scaledSafeAreaWidth
      height: Math.round scaledSafeAreaHeight

    @viewport
      viewportBounds: viewportBounds
      maxBounds: maxBounds
      safeArea: safeArea
