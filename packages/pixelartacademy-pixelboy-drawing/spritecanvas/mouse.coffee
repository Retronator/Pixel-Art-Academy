class PixelArtAcademy.PixelBoy.Apps.Drawing.SpriteCanvas.Mouse
  constructor: (@spriteCanvas) ->
    # The mouse coordinate relative to sprite canvas in native window (browser) pixels.
    @windowCoordinate = new ReactiveField null, EJSON.equals

    # The mouse coordinate relative to sprite canvas as measured in display pixels (as scaled by AM.Display).
    @displayCoordinate = new ReactiveField null, EJSON.equals

    # The floating point value where the mouse is in canvas' coordinate system.
    @canvasCoordinate = new ReactiveField null, EJSON.equals

    # The integer value of sprite's pixel the mouse is hovering over.
    @pixelCoordinate = new ReactiveField null, EJSON.equals

    # Wire up mousemove and scroll events once the sprite editor is rendered.
    @spriteCanvas.autorun (computation) =>
      $spriteCanvas = @spriteCanvas.$spriteCanvas()
      camera = @spriteCanvas.camera()

      return unless $spriteCanvas
      computation.stop()

      $content = $spriteCanvas.find('.content')

      $spriteCanvas.on 'mousemove.spriteCanvas', (event) =>
        origin = $content.offset()
        displayScale = @spriteCanvas.drawing.os.display.scale()

        windowCoordinate =
          x: event.pageX - origin.left
          y: event.pageY - origin.top

        @windowCoordinate windowCoordinate

        # We offset by one display pixel to compensate for cursor shape (experimentally determined).
        displayCoordinate =
          x: windowCoordinate.x / displayScale - 1
          y: windowCoordinate.y / displayScale - 1

        @displayCoordinate displayCoordinate

        canvasCoordinate = camera.transformToCanvas displayCoordinate
        @canvasCoordinate canvasCoordinate

        pixelCoordinate =
          x: Math.floor canvasCoordinate.x
          y: Math.floor canvasCoordinate.y

        @pixelCoordinate pixelCoordinate

      # Zoom with scrolling.
      onScroll = _.throttle (event) =>
        @spriteCanvas.drawing.navigator().zoomIn() if event.originalEvent.wheelDeltaY > 0
        @spriteCanvas.drawing.navigator().zoomOut() if event.originalEvent.wheelDeltaY < 0

      , 100, trailing: false

      $spriteCanvas.closest('.apps-drawing').on 'mousewheel.spriteCanvas', (event) =>
        event.preventDefault()
        return unless event.originalEvent.wheelDeltaY

        onScroll event
