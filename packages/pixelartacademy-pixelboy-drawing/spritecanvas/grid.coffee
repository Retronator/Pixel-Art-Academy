class PixelArtAcademy.PixelBoy.Apps.Drawing.SpriteCanvas.Grid
  constructor: (@spriteCanvas) ->

  draw: ->
    context = @spriteCanvas.context()
    camera = @spriteCanvas.camera()
    scale = camera.scale()
    canvasBounds = @spriteCanvas.canvasBounds.toObject()

    # Determine grid opacity (scale < 2: 0, scale > 32: 0.3)
    gridOpacity = (scale - 2) / 100
    gridOpacity = THREE.Math.clamp gridOpacity, 0, 0.3

    return unless gridOpacity > 0

    context.strokeStyle = "rgba(0,0,0,#{gridOpacity})"
    context.lineWidth = 1 / scale
    context.beginPath()

    for y in [canvasBounds.top..canvasBounds.bottom]
      pixelPerfectCoordinate = camera.roundToDisplayPixel x:0, y:y
      context.moveTo canvasBounds.left, pixelPerfectCoordinate.y
      context.lineTo canvasBounds.right, pixelPerfectCoordinate.y

    for x in [canvasBounds.left..canvasBounds.right]
      pixelPerfectCoordinate = camera.roundToDisplayPixel x:x, y:0
      context.moveTo pixelPerfectCoordinate.x, canvasBounds.top
      context.lineTo pixelPerfectCoordinate.x, canvasBounds.bottom

    context.stroke()
