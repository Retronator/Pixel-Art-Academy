AE = Artificial.Everywhere

class PixelArtAcademy.PixelBoy.Apps.Drawing.SpriteCanvas.Camera
  constructor: (@spriteCanvas, scale = 1) ->

    @scale = new ReactiveField scale, EJSON.equals

  setTransformToCanvas: ->
    context = @spriteCanvas.context()
    scale = @scale()

    # Start from the identity.
    context.setTransform 1, 0, 0, 1, 0, 0

    # Scale the canvas.
    context.scale scale, scale

  transformToDisplay: (canvasCoordinate) ->
    scale = @scale()

    x: canvasCoordinate.x * scale
    y: canvasCoordinate.y * scale

  transformToCanvas: (displayCoordinate) ->
    scale = @scale()

    x: displayCoordinate.x / scale
    y: displayCoordinate.y / scale

  roundToDisplayPixel: (canvasCoordinate) ->
    # When drawing to canvas, a pixel perfect 1px line needs
    # to be 0.5 offset (the line is centered around the coordinate)
    displayCoordinate = @transformToDisplay canvasCoordinate
    pixelPerfectDisplayCoordinate =
      x: Math.floor(displayCoordinate.x) + 0.5
      y: Math.floor(displayCoordinate.y) + 0.5

    @transformToCanvas pixelPerfectDisplayCoordinate
